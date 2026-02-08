#!/usr/bin/env node
/**
 * 프롬프트 자동 저장 Hook
 *
 * Claude Code의 user-prompt-submit hook에서 실행됩니다.
 * stdin으로 전달된 프롬프트를 prompt/personal_prompt.md에 저장합니다.
 * 또한 세션 디렉토리 경로를 탐색하여 .claude/.session-path-cache에 캐싱합니다.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// 프로젝트 루트 찾기
const projectRoot = process.cwd();
const promptFile = path.join(projectRoot, 'prompt', 'personal_prompt.md');

/**
 * 세션 디렉토리 경로를 탐색하여 캐싱
 * Strategy A: 현재 경로를 인코딩하여 직접 매칭
 * Strategy B: sessions-index.json의 originalPath로 매칭 (fallback)
 */
function discoverSessionPath() {
  try {
    const home = os.homedir();
    const claudeProjectsDir = path.join(home, '.claude', 'projects');

    if (!fs.existsSync(claudeProjectsDir)) {
      return null;
    }

    // Strategy A: 현재 경로를 인코딩하여 직접 매칭
    // C:\dev\02_agent → C--dev-02_agent (Windows)
    // /Users/p/dev/project → -Users-p-dev-project (Mac)
    const encoded = projectRoot
      .replace(/:/g, '')
      .replace(/[\\/]/g, '-');

    const directPath = path.join(claudeProjectsDir, encoded);
    if (fs.existsSync(directPath)) {
      return directPath;
    }

    // Strategy B: sessions-index.json의 originalPath로 매칭
    const entries = fs.readdirSync(claudeProjectsDir, { withFileTypes: true });
    for (const entry of entries) {
      if (!entry.isDirectory()) continue;

      const indexFile = path.join(claudeProjectsDir, entry.name, 'sessions-index.json');
      if (!fs.existsSync(indexFile)) continue;

      try {
        const indexContent = fs.readFileSync(indexFile, 'utf8');
        const indexData = JSON.parse(indexContent);

        // originalPath 필드가 현재 경로와 일치하는지 확인
        if (indexData.originalPath) {
          const normalizedOriginal = path.normalize(indexData.originalPath);
          const normalizedCwd = path.normalize(projectRoot);
          if (normalizedOriginal === normalizedCwd) {
            return path.join(claudeProjectsDir, entry.name);
          }
        }

        // 각 세션 항목에서도 경로 확인
        if (Array.isArray(indexData)) {
          for (const session of indexData) {
            if (session.originalPath) {
              const normalizedOriginal = path.normalize(session.originalPath);
              const normalizedCwd = path.normalize(projectRoot);
              if (normalizedOriginal === normalizedCwd) {
                return path.join(claudeProjectsDir, entry.name);
              }
            }
          }
        }
      } catch (e) {
        // 파싱 에러 무시, 다음 폴더로
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}

/**
 * 세션 경로를 .claude/.session-path-cache에 저장
 */
function cacheSessionPath() {
  try {
    const sessionPath = discoverSessionPath();
    const cacheFile = path.join(projectRoot, '.claude', '.session-path-cache');

    if (sessionPath) {
      // .claude 디렉토리 확인
      const claudeDir = path.join(projectRoot, '.claude');
      if (!fs.existsSync(claudeDir)) {
        fs.mkdirSync(claudeDir, { recursive: true });
      }
      fs.writeFileSync(cacheFile, sessionPath, 'utf8');
    }
  } catch (e) {
    // 에러 무시
  }
}

// stdin에서 프롬프트 읽기
let input = '';
process.stdin.setEncoding('utf8');

process.stdin.on('data', (chunk) => {
  input += chunk;
});

process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const prompt = data.prompt || data.message || input;

    // 빈 프롬프트 무시
    if (!prompt || prompt.trim() === '') {
      process.exit(0);
    }

    // 슬래시 명령어는 저장하지 않음
    if (prompt.trim().startsWith('/')) {
      process.exit(0);
    }

    // 타임스탬프 생성
    const now = new Date();
    const timestamp = now.toISOString().slice(0, 16).replace('T', ' ');

    // 저장할 내용
    const entry = `\n## [${timestamp}]\n\n${prompt.trim()}\n\n---\n`;

    // 디렉토리 확인/생성
    const promptDir = path.dirname(promptFile);
    if (!fs.existsSync(promptDir)) {
      fs.mkdirSync(promptDir, { recursive: true });
    }

    // 파일에 추가
    fs.appendFileSync(promptFile, entry, 'utf8');

    // 프롬프트 개수 확인 (자동 분석 트리거용)
    const content = fs.readFileSync(promptFile, 'utf8');
    const promptCount = (content.match(/^## \[/gm) || []).length;

    // 10개마다 분석 제안 플래그 파일 생성
    if (promptCount > 0 && promptCount % 10 === 0) {
      const flagFile = path.join(projectRoot, '.claude', '.analyze-trigger');
      fs.writeFileSync(flagFile, `${promptCount}`, 'utf8');
    }

    // 세션 경로 탐색 및 캐싱
    cacheSessionPath();

  } catch (e) {
    // 에러 무시 (hook 실패가 사용자 경험 방해하면 안됨)
  }

  process.exit(0);
});
