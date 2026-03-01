<div _ngcontent-serverapp-c2986055506="" id="main-content" tabindex="0" appmainelement="" class="main-content"><d360-breadcrumb _nghost-serverapp-c4227853843="" ng-version="19.2.14"><d360-smart-bar-initializer _ngcontent-serverapp-c4227853843=""><!----></d360-smart-bar-initializer><!----><div _ngcontent-serverapp-c4227853843="" class="breadcrumb-nav"><ul _ngcontent-serverapp-c4227853843="" class="secondaryUL"><!----><!----><li _ngcontent-serverapp-c4227853843="" class="no-arrow min-w-0"><ul _ngcontent-serverapp-c4227853843="" class="scroll-by-button-container breadcrumb-scroll"><li _ngcontent-serverapp-c4227853843="" class="no-arrow"><a _ngcontent-serverapp-c4227853843="" href="/docs">홈</a><!----><!----></li><li _ngcontent-serverapp-c4227853843=""><a _ngcontent-serverapp-c4227853843="" href="/docs/ai-application-service-geolocation">Application Services</a><!----><!----></li><li _ngcontent-serverapp-c4227853843="" class="current"><a _ngcontent-serverapp-c4227853843="" href="/docs/application-maps-overview">Maps</a><!----><!----></li><!----></ul><!----></li><!----></ul></div></d360-breadcrumb><!----><!----><d360-article-header _nghost-serverapp-c1860386753="" ng-version="19.2.14"><!----><!----><!----><div _ngcontent-serverapp-c1860386753="" class="d-flex justify-content-between align-items-center mb-3"><h1 _ngcontent-serverapp-c1860386753="" class="article-title"><!----> Geocoding <d360-copy-article-link _ngcontent-serverapp-c1860386753="" _nghost-serverapp-c3783284290=""><button _ngcontent-serverapp-c3783284290="" class="btn btn-secondary btn-icon copy-article" aria-label="Copy link of Geocoding"><i _ngcontent-serverapp-c3783284290="" class="fa-regular fa-link-horizontal"></i></button><!----><!----></d360-copy-article-link><!----></h1><!----></div><!----><div _ngcontent-serverapp-c1860386753="" class="article-info"><!----><!----><div _ngcontent-serverapp-c1860386753="" class="article-info-bottom"><div _ngcontent-serverapp-c1860386753="" class="article-contributors"><!----></div><div _ngcontent-serverapp-c1860386753="" class="article-more-options"><!----><d360-follow-unfollow _ngcontent-serverapp-c1860386753="" _nghost-serverapp-c995546829=""><!----></d360-follow-unfollow><!----><!----><d360-social-sharing _ngcontent-serverapp-c1860386753="" _nghost-serverapp-c3502761724=""><div _ngcontent-serverapp-c3502761724="" ngbdropdown="" container="body" class="d-inline-block dropdown"><button _ngcontent-serverapp-c3502761724="" type="button" id="article-social-sharing-options" aria-label="Article social sharing" ngbdropdowntoggle="" class="dropdown-toggle btn btn-icon btn-secondary toggle-icon-none" aria-expanded="false"><i _ngcontent-serverapp-c3502761724="" aria-hidden="true" class="fa-regular fa-share-nodes"></i></button><!----><div _ngcontent-serverapp-c3502761724="" ngbdropdownmenu="" aria-labelledby="article-social-sharing-options" class="dropdown-menu share-dropdown"><button _ngcontent-serverapp-c3502761724="" ngbdropdownitem="" aria-label="Twitter" class="dropdown-item" tabindex="0"><i _ngcontent-serverapp-c3502761724="" aria-hidden="true" class="fa-brands fa-x-twitter"></i></button><!----><button _ngcontent-serverapp-c3502761724="" ngbdropdownitem="" aria-label="Linkedin" class="dropdown-item" tabindex="0"><i _ngcontent-serverapp-c3502761724="" aria-hidden="true" class="fa-brands fa-linkedin"></i></button><!----><button _ngcontent-serverapp-c3502761724="" ngbdropdownitem="" aria-label="Facebook" class="dropdown-item" tabindex="0"><i _ngcontent-serverapp-c3502761724="" aria-hidden="true" class="fa-brands fa-facebook"></i></button><!----><button _ngcontent-serverapp-c3502761724="" ngbdropdownitem="" aria-label="Email" class="dropdown-item" tabindex="0"><i _ngcontent-serverapp-c3502761724="" aria-hidden="true" class="fa-solid fa-envelope"></i></button><!----></div></div><!----></d360-social-sharing><!----><d360-article-more-options _ngcontent-serverapp-c1860386753=""><div ngbdropdown="" autoclose="outside" container="body" class="d-inline-block dropdown"><button type="button" aria-label="Article more options" ngbdropdowntoggle="" class="dropdown-toggle btn btn-icon btn-secondary toggle-icon-none" id="913131e4-6278-4ec9-a54e-861980e77ec2" aria-expanded="false"><i class="fa-solid fa-ellipsis"></i></button><div ngbdropdownmenu="" class="dropdown-menu"><!----><button ngbdropdownitem="" class="dropdown-item" tabindex="0"><i class="fa-regular fa-arrow-up-from-bracket"></i> PDF 내보내기 <!----></button><!----><button ngbdropdownitem="" class="dropdown-item" tabindex="0"><i class="fa-regular fa-print"></i> 인쇄 </button><!----></div></div><!----><!----><!----><!----><!----></d360-article-more-options><!----><!----><!----><!----></div></div><!----></div><!----><!----><!----><!----><!----><!----><!----><!----></d360-article-header><!----><!----><d360-article-content _nghost-serverapp-c3297765830="" ng-version="19.2.14"><!----><span _ngcontent-serverapp-c3297765830="" class="non-visibility-content" style="display: block; width: 100%;"><span _ngcontent-serverapp-c3297765830=""><a _ngcontent-serverapp-c3297765830="" href="/docs/application-maps-static" title="Static Map"> Prev </a></span><!----><span _ngcontent-serverapp-c3297765830="" style="float: right;"><a _ngcontent-serverapp-c3297765830="" href="/docs/application-maps-reversegeocoding" title="Reverse Geocoding"> Next </a></span><!----></span><!----><!----><!----><article _ngcontent-serverapp-c3297765830="" id="articleContent" appglossaryrenderer="" appimageviewer="" apphighlight="" appeditor360tabs="" appeditor360tableshadow="" appfloikpreview="" appfiledownload="" class="editor360-published-content md-article"><p class="platform-info type-vpc" data-tomark-pass="">VPC 환경에서 이용 가능합니다.</p>
<p>입력한 주소와 연관된 주소 정보를 검색합니다.</p>
<h2 id="요청" class="hyperlink-wrapper-container">요청 <a name="요청" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="요청" aria-label="Copy link to 요청"><i class="fa-regular fa-link-horizontal"></i></button></h2>
<p>요청 형식을 설명합니다. 요청 형식은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">메서드</th>
<th style="text-align:left">URI</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left">GET</td>
<td style="text-align:left">/geocode</td>
</tr>
</tbody>
</table>
<h3 id="요청-헤더" class="hyperlink-wrapper-container">요청 헤더 <a name="요청헤더" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="요청-헤더" aria-label="Copy link to 요청 헤더"><i class="fa-regular fa-link-horizontal"></i></button></h3>
<p>요청 헤더에 대한 설명은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">필드</th>
<th style="text-align:left">필수 여부</th>
<th style="text-align:left">설명</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left"><code data-backticks="1">Accept</code></td>
<td style="text-align:left">Required</td>
<td style="text-align:left">응답 데이터의 형식<ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">application/json</code></li></ul></td>
</tr>
</tbody>
</table>
<p>Maps API에서 공통으로 사용하는 헤더에 대한 정보는 <a href="/docs/application-maps-overview#%EC%9A%94%EC%B2%AD%ED%97%A4%EB%8D%94" rel="noopener">Maps 공통 헤더</a>를 참조해 주십시오.</p>
<h3 id="요청-쿼리-파라미터" class="hyperlink-wrapper-container">요청 쿼리 파라미터 <a name="요청쿼리파라미터" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="요청-쿼리-파라미터" aria-label="Copy link to 요청 쿼리 파라미터"><i class="fa-regular fa-link-horizontal"></i></button></h3>
<p>요청 쿼리 파라미터에 대한 설명은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">필드</th>
<th style="text-align:left">타입</th>
<th style="text-align:left">필수 여부</th>
<th style="text-align:left">설명</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left"><code data-backticks="1">query</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">Required</td>
<td style="text-align:left">검색할 주소</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">coordinate</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">Optional</td>
<td style="text-align:left">검색 중심 좌표(경도,위도)<ul data-tomark-pass=""><li data-tomark-pass="">입력한 좌표와 근접한 순으로 검색 결과 표시</li></ul></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">filter</code></td>
<td style="text-align:left">Integer</td>
<td style="text-align:left">Optional</td>
<td style="text-align:left">검색 결과 필터<ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">HCODE</code> | <code data-backticks="1">BCODE</code><ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">hCODE</code>: 행정동 코드</li><li data-tomark-pass=""><code data-backticks="1">BCODE</code>: 법정동 코드</li></ul></li><li data-tomark-pass=""><strong>필터 타입@코드1;코드2;......</strong> 형식으로 입력</li><li data-tomark-pass="">&lt;예시&gt; <code data-backticks="1">HCODE@4113554500;4113555000</code></li></ul></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">language</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">Optional</td>
<td style="text-align:left">응답 결과 언어<ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">kor</code> (기본값) | <code data-backticks="1">eng</code><ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">kor</code>: 한국어</li><li data-tomark-pass=""><code data-backticks="1">eng</code>: 영어</li></ul></li></ul></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">page</code></td>
<td style="text-align:left">Number</td>
<td style="text-align:left">Optional</td>
<td style="text-align:left">페이지 번호<ul data-tomark-pass=""><li data-tomark-pass="">1 (기본값)</li></ul></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">count</code></td>
<td style="text-align:left">Number</td>
<td style="text-align:left">Optional</td>
<td style="text-align:left">결과 목록 크기<ul data-tomark-pass=""><li data-tomark-pass="">1~100 (기본값: 10)</li></ul></td>
</tr>
</tbody>
</table>
<h3 id="요청-예시" class="hyperlink-wrapper-container">요청 예시 <a name="요청예시" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="요청-예시" aria-label="Copy link to 요청 예시"><i class="fa-regular fa-link-horizontal"></i></button></h3>
<p>요청 예시는 다음과 같습니다.</p>
<div class="code-toolbar"><pre class="language-shell" tabindex="0"><code data-language="Shell" class="language-shell"><span class="token function">curl</span> <span class="token parameter variable">--location</span> <span class="token parameter variable">--request</span> GET <span class="token string">'https://maps.apigw.ntruss.com/map-geocode/v2/geocode?query=분당구 불정로 6'</span> <span class="token punctuation">\</span>
<span class="token parameter variable">--header</span> <span class="token string">'x-ncp-apigw-api-key-id: {API Key ID}'</span> <span class="token punctuation">\</span>
<span class="token parameter variable">--header</span> <span class="token string">'x-ncp-apigw-api-key: {API Key}'</span> <span class="token punctuation">\</span>
<span class="token parameter variable">--header</span> <span class="token string">'Accept: application/json'</span>
</code></pre><div class="toolbar"><div class="toolbar-item"><span>Shell</span></div><div class="toolbar-item"><button class="copy-to-clipboard-button" type="button" data-copy-state="copy"><span>Copy</span></button></div></div></div>
<h2 id="응답" class="hyperlink-wrapper-container">응답 <a name="응답" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="응답" aria-label="Copy link to 응답"><i class="fa-regular fa-link-horizontal"></i></button></h2>
<p>응답 형식을 설명합니다.</p>
<h3 id="응답-바디" class="hyperlink-wrapper-container">응답 바디 <a name="응답바디" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="응답-바디" aria-label="Copy link to 응답 바디"><i class="fa-regular fa-link-horizontal"></i></button></h3>
<p>응답 바디에 대한 설명은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">필드</th>
<th style="text-align:left">타입</th>
<th style="text-align:left">필수 여부</th>
<th style="text-align:left">설명</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left"><code data-backticks="1">status</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">응답 코드</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">meta</code></td>
<td style="text-align:left">Object</td>
<td style="text-align:left">-</td>
<td style="text-align:left">메타 데이터</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">meta.totalCount</code></td>
<td style="text-align:left">Number</td>
<td style="text-align:left">-</td>
<td style="text-align:left">응답 결과 개수</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">meta.page</code></td>
<td style="text-align:left">Number</td>
<td style="text-align:left">-</td>
<td style="text-align:left">현재 페이지 번호</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">meta.count</code></td>
<td style="text-align:left">Number</td>
<td style="text-align:left">-</td>
<td style="text-align:left">페이지 내 결과 개수</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">addresses</code></td>
<td style="text-align:left">Array</td>
<td style="text-align:left">-</td>
<td style="text-align:left"><a href="/docs/application-maps-geocoding#addresses" rel="noopener">주소 정보 목록</a></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">errorMessage</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">오류 메시지<ul data-tomark-pass=""><li data-tomark-pass="">500 오류(알 수 없는 오류) 발생 시에만 표시</li></ul></td>
</tr>
</tbody>
</table>
<h4 id="addresses"><code data-backticks="1">addresses</code> <a name="addresses" data-tomark-pass=""></a></h4>
<p><code data-backticks="1">addresses</code>에 대한 설명은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">필드</th>
<th style="text-align:left">타입</th>
<th style="text-align:left">필수 여부</th>
<th style="text-align:left">설명</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left"><code data-backticks="1">roadAddress</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">도로명 주소</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">jibunAddress</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">지번 주소</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">englishAddress</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">영어 주소</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">addressElements</code></td>
<td style="text-align:left">Array</td>
<td style="text-align:left">-</td>
<td style="text-align:left"><a href="/docs/application-maps-geocoding#addressElements" rel="noopener">주소 구성 요소 정보</a></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">x</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">X 좌표(경도)</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">y</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">Y 좌표(위도)</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">distance</code></td>
<td style="text-align:left">Double</td>
<td style="text-align:left">-</td>
<td style="text-align:left">중심 좌표로부터의 거리(m)</td>
</tr>
</tbody>
</table>
<h4 id="addresselements"><code data-backticks="1">addressElements</code> <a name="addressElements" data-tomark-pass=""></a></h4>
<p><code data-backticks="1">addressElements</code>에 대한 설명은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">필드</th>
<th style="text-align:left">타입</th>
<th style="text-align:left">필수 여부</th>
<th style="text-align:left">설명</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left"><code data-backticks="1">type</code></td>
<td style="text-align:left">Array</td>
<td style="text-align:left">-</td>
<td style="text-align:left">주소 구성 요소 타입<ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">SIDO</code> | <code data-backticks="1">SIGUGUN</code> | <code data-backticks="1">DONGMYUN</code> | <code data-backticks="1">RI</code> | <code data-backticks="1">ROAD_NAME</code> | <code data-backticks="1">BUILDING_NUMBER</code> | <code data-backticks="1">BUILDING_NAME</code> | <code data-backticks="1">LAND_NUMBER</code> | <code data-backticks="1">POSTAL_CODE</code><ul data-tomark-pass=""><li data-tomark-pass=""><code data-backticks="1">SIDO</code>: 시/도</li><li data-tomark-pass=""><code data-backticks="1">SIGUGUN</code>: 시/구/군</li><li data-tomark-pass=""><code data-backticks="1">DONGMYUN</code>: 동/면</li><li data-tomark-pass=""><code data-backticks="1">RI</code>: 리</li><li data-tomark-pass=""><code data-backticks="1">ROAD_NAME</code>: 도로명</li><li data-tomark-pass=""><code data-backticks="1">BUILDING_NUMBER</code>: 건물 번호</li><li data-tomark-pass=""><code data-backticks="1">BUILDING_NAME</code>: 건물 이름</li><li data-tomark-pass=""><code data-backticks="1">LAND_NUMBER</code>: 번지</li><li data-tomark-pass=""><code data-backticks="1">POSTAL_CODE</code>: 우편번호</li></ul></li></ul></td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">longName</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">주소 구성 요소 이름</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">shortName</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">주소 구성 요소 축약 이름</td>
</tr>
<tr>
<td style="text-align:left"><code data-backticks="1">code</code></td>
<td style="text-align:left">String</td>
<td style="text-align:left">-</td>
<td style="text-align:left">-</td>
</tr>
</tbody>
</table>
<h3 id="응답-상태-코드" class="hyperlink-wrapper-container">응답 상태 코드 <a name="응답상태코드" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="응답-상태-코드" aria-label="Copy link to 응답 상태 코드"><i class="fa-regular fa-link-horizontal"></i></button></h3>
<p>응답 상태 코드에 대한 설명은 다음과 같습니다.</p>
<table>
<thead>
<tr>
<th style="text-align:left">HTTP 상태 코드</th>
<th style="text-align:left">코드</th>
<th style="text-align:left">메시지</th>
<th style="text-align:left">설명</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left">200</td>
<td style="text-align:left">OK</td>
<td style="text-align:left">-</td>
<td style="text-align:left">요청 처리 성공. 정상 응답</td>
</tr>
<tr>
<td style="text-align:left">400</td>
<td style="text-align:left">INVALID_REQUEST</td>
<td style="text-align:left">-</td>
<td style="text-align:left">요청 오류</td>
</tr>
<tr>
<td style="text-align:left">500</td>
<td style="text-align:left">SYSTEM_ERROR</td>
<td style="text-align:left">Unexpected Error</td>
<td style="text-align:left">알 수 없는 오류</td>
</tr>
</tbody>
</table>
<section class="infoBox">
          <div class="title">참고
</div>
          <div class="content"><p>Maps API에서 공통으로 사용하는 응답 상태 코드에 대한 정보는 <a href="/docs/application-maps-overview#%EC%9D%91%EB%8B%B5%EC%83%81%ED%83%9C%EC%BD%94%EB%93%9C" rel="noopener">Maps 공통 응답 상태 코드</a>를 참조해 주십시오.</p>
</div></section>
<h3 id="응답-예시" class="hyperlink-wrapper-container">응답 예시 <a name="응답예시" data-tomark-pass=""></a><button class="copy-link-btn btn btn-secondary btn-icon" data-heading-id="응답-예시" aria-label="Copy link to 응답 예시"><i class="fa-regular fa-link-horizontal"></i></button></h3>
<p>응답 예시는 다음과 같습니다.</p>
<div class="code-toolbar"><pre class="language-json" tabindex="0"><code data-language="JSON" class="language-json"><span class="token punctuation">{</span>
    <span class="token property">"status"</span><span class="token operator">:</span> <span class="token string">"OK"</span><span class="token punctuation">,</span>
    <span class="token property">"meta"</span><span class="token operator">:</span> <span class="token punctuation">{</span>
        <span class="token property">"totalCount"</span><span class="token operator">:</span> <span class="token number">1</span><span class="token punctuation">,</span>
        <span class="token property">"page"</span><span class="token operator">:</span> <span class="token number">1</span><span class="token punctuation">,</span>
        <span class="token property">"count"</span><span class="token operator">:</span> <span class="token number">1</span>
    <span class="token punctuation">}</span><span class="token punctuation">,</span>
    <span class="token property">"addresses"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
        <span class="token punctuation">{</span>
            <span class="token property">"roadAddress"</span><span class="token operator">:</span> <span class="token string">"경기도 성남시 분당구 불정로 6 NAVER그린팩토리"</span><span class="token punctuation">,</span>
            <span class="token property">"jibunAddress"</span><span class="token operator">:</span> <span class="token string">"경기도 성남시 분당구 정자동 178-1 NAVER그린팩토리"</span><span class="token punctuation">,</span>
            <span class="token property">"englishAddress"</span><span class="token operator">:</span> <span class="token string">"6, Buljeong-ro, Bundang-gu, Seongnam-si, Gyeonggi-do, Republic of Korea"</span><span class="token punctuation">,</span>
            <span class="token property">"addressElements"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"SIDO"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"경기도"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"경기도"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"SIGUGUN"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"성남시 분당구"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"성남시 분당구"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"DONGMYUN"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"정자동"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"정자동"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"RI"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">""</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">""</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"ROAD_NAME"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"불정로"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"불정로"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"BUILDING_NUMBER"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"6"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"6"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"BUILDING_NAME"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"NAVER그린팩토리"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"NAVER그린팩토리"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"LAND_NUMBER"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"178-1"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"178-1"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span><span class="token punctuation">,</span>
                <span class="token punctuation">{</span>
                    <span class="token property">"types"</span><span class="token operator">:</span> <span class="token punctuation">[</span>
                        <span class="token string">"POSTAL_CODE"</span>
                    <span class="token punctuation">]</span><span class="token punctuation">,</span>
                    <span class="token property">"longName"</span><span class="token operator">:</span> <span class="token string">"13561"</span><span class="token punctuation">,</span>
                    <span class="token property">"shortName"</span><span class="token operator">:</span> <span class="token string">"13561"</span><span class="token punctuation">,</span>
                    <span class="token property">"code"</span><span class="token operator">:</span> <span class="token string">""</span>
                <span class="token punctuation">}</span>
            <span class="token punctuation">]</span><span class="token punctuation">,</span>
            <span class="token property">"x"</span><span class="token operator">:</span> <span class="token string">"127.1054328"</span><span class="token punctuation">,</span>
            <span class="token property">"y"</span><span class="token operator">:</span> <span class="token string">"37.3595963"</span><span class="token punctuation">,</span>
            <span class="token property">"distance"</span><span class="token operator">:</span> <span class="token number">0.0</span>
        <span class="token punctuation">}</span>
    <span class="token punctuation">]</span><span class="token punctuation">,</span>
    <span class="token property">"errorMessage"</span><span class="token operator">:</span> <span class="token string">""</span>
<span class="token punctuation">}</span>
</code></pre><div class="toolbar"><div class="toolbar-item"><span>JSON</span></div><div class="toolbar-item"><button class="copy-to-clipboard-button" type="button" data-copy-state="copy"><span>Copy</span></button></div></div></div>
</article><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></d360-article-content><!----><!----><!----><d360-article-feedback _nghost-serverapp-c2334917121="" ng-version="19.2.14"><div _ngcontent-serverapp-c2334917121="" class="feedback-container"><p _ngcontent-serverapp-c2334917121="" class="text-center m-0 p-0"></p><div _ngcontent-serverapp-c2334917121="" class="article-feedback"><div _ngcontent-serverapp-c2334917121="" class="article-feedback-text"> 이 문서가 도움이 되었습니까? </div><div _ngcontent-serverapp-c2334917121="" class="article-feedback-action"><button _ngcontent-serverapp-c2334917121="" aria-label="Yes" triggers="manual" class="btn btn-outline-secondary"><i _ngcontent-serverapp-c2334917121="" aria-hidden="true" class="fa-duotone fa-thumbs-up"></i> 예 </button><!----><button _ngcontent-serverapp-c2334917121="" aria-label="No" triggers="manual" class="btn btn-outline-secondary"><i _ngcontent-serverapp-c2334917121="" aria-hidden="true" class="fa-duotone fa-thumbs-down"></i> 아니요 </button><!----></div></div><!----></div><!----><!----><!----><!----><!----><!----><!----><!----><!----><!----></d360-article-feedback><!----><!----><d360-article-navigator _nghost-serverapp-c3660770874="" ng-version="19.2.14"><div _ngcontent-serverapp-c3660770874=""><div _ngcontent-serverapp-c3660770874="" class="article-navigation mb-3 justify-content-start"><button _ngcontent-serverapp-c3660770874="" tabindex="0" role="button" class="article-previous cursor-pointer" aria-label="Static Map"><div _ngcontent-serverapp-c3660770874="" class="me-2"><i _ngcontent-serverapp-c3660770874="" class="fa-regular fa-arrow-left"></i></div><div _ngcontent-serverapp-c3660770874="" class="article-navigation-content"><div _ngcontent-serverapp-c3660770874="" class="article-navigation-des"> 이전 </div><div _ngcontent-serverapp-c3660770874="" class="fw-bold text-truncate text-nowrap title pt-1">Static Map</div></div></button><!----><button _ngcontent-serverapp-c3660770874="" tabindex="0" role="button" class="article-next cursor-pointer" aria-label="Reverse Geocoding"><div _ngcontent-serverapp-c3660770874="" class="article-navigation-content"><div _ngcontent-serverapp-c3660770874="" class="article-navigation-des"> 다음 </div><div _ngcontent-serverapp-c3660770874="" class="fw-bold text-truncate text-nowrap title pt-1">Reverse Geocoding</div></div><div _ngcontent-serverapp-c3660770874="" class="ms-2"><i _ngcontent-serverapp-c3660770874="" class="fa-regular fa-arrow-right"></i></div></button><!----></div><!----></div><!----></d360-article-navigator><!----><!----><!----><d360-smart-bar-initializer _ngcontent-serverapp-c2986055506=""><!----></d360-smart-bar-initializer><!----><d360-inline-integrations _ngcontent-serverapp-c2986055506=""></d360-inline-integrations><!----><!----></div>
