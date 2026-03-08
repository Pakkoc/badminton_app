import 'package:badminton_app/models/community_comment.dart';
import 'package:badminton_app/models/community_post.dart';
import 'package:badminton_app/models/community_report.dart';
import 'package:badminton_app/models/enums.dart';
import 'package:badminton_app/models/inventory_item.dart';
import 'package:badminton_app/models/member.dart';
import 'package:badminton_app/models/notification_item.dart';
import 'package:badminton_app/models/order.dart';
import 'package:badminton_app/models/post.dart';
import 'package:badminton_app/models/shop.dart';
import 'package:badminton_app/models/user.dart';

final testUser = User(
  id: '550e8400-e29b-41d4-a716-446655440000',
  role: UserRole.customer,
  name: '홍길동',
  phone: '01012345678',
  createdAt: DateTime(2026, 1, 1),
);

final testOwner = User(
  id: '550e8400-e29b-41d4-a716-446655440099',
  role: UserRole.shopOwner,
  name: '김사장',
  phone: '01098765432',
  createdAt: DateTime(2026, 1, 1),
);

final testShop = Shop(
  id: '660e8400-e29b-41d4-a716-446655440001',
  ownerId: '550e8400-e29b-41d4-a716-446655440099',
  name: '거트 프로샵',
  address: '서울시 강남구 역삼동 123',
  latitude: 37.4979,
  longitude: 127.0276,
  phone: '0212345678',
  description: '최고의 거트 서비스',
  status: ShopStatus.approved,
  createdAt: DateTime(2026, 1, 1),
);

final testMember = Member(
  id: '770e8400-e29b-41d4-a716-446655440002',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  userId: '550e8400-e29b-41d4-a716-446655440000',
  name: '홍길동',
  phone: '01012345678',
  visitCount: 5,
  createdAt: DateTime(2026, 1, 1),
);

final testOrderReceived = GutOrder(
  id: '880e8400-e29b-41d4-a716-446655440003',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  memberId: '770e8400-e29b-41d4-a716-446655440002',
  status: OrderStatus.received,
  memo: '2본 작업',
  createdAt: DateTime(2026, 1, 15, 10),
  updatedAt: DateTime(2026, 1, 15, 10),
);

final testOrderInProgress = testOrderReceived.copyWith(
  status: OrderStatus.inProgress,
  inProgressAt: DateTime(2026, 1, 15, 11),
  updatedAt: DateTime(2026, 1, 15, 11),
);

final testOrderCompleted = testOrderReceived.copyWith(
  status: OrderStatus.completed,
  inProgressAt: DateTime(2026, 1, 15, 11),
  completedAt: DateTime(2026, 1, 15, 12),
  updatedAt: DateTime(2026, 1, 15, 12),
);

final testPostNotice = Post(
  id: '990e8400-e29b-41d4-a716-446655440004',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  category: PostCategory.notice,
  title: '영업시간 변경 안내',
  content: '이번 주부터 영업시간이 변경됩니다.',
  images: ['https://example.com/img1.jpg'],
  createdAt: DateTime(2026, 1, 20, 9),
);

final testPostEvent = Post(
  id: '990e8400-e29b-41d4-a716-446655440005',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  category: PostCategory.event,
  title: '봄맞이 할인',
  content: '거트 교체 20% 할인!',
  images: [],
  eventStartDate: DateTime(2026, 3, 1),
  eventEndDate: DateTime(2026, 3, 31),
  createdAt: DateTime(2026, 2, 20, 9),
);

final testInventoryItem = InventoryItem(
  id: 'aa0e8400-e29b-41d4-a716-446655440006',
  shopId: '660e8400-e29b-41d4-a716-446655440001',
  name: 'BG65',
  category: InventoryCategory.other,
  quantity: 50,
  imageUrl: 'https://example.com/bg65.jpg',
  createdAt: DateTime(2026, 1, 10, 9),
);

final testNotification = NotificationItem(
  id: 'bb0e8400-e29b-41d4-a716-446655440007',
  userId: '550e8400-e29b-41d4-a716-446655440000',
  type: NotificationType.statusChange,
  title: '작업 상태 변경',
  body: '거트 프로샵에서 작업이 시작되었습니다.',
  orderId: '880e8400-e29b-41d4-a716-446655440003',
  createdAt: DateTime(2026, 1, 15, 11),
);

final testCommunityPost = CommunityPost(
  id: 'cc0e8400-e29b-41d4-a716-446655440010',
  authorId: '550e8400-e29b-41d4-a716-446655440000',
  title: '배드민턴 라켓 추천해주세요',
  content: '초보자용 라켓 추천 부탁드립니다.',
  images: ['https://example.com/community1.jpg'],
  likeCount: 3,
  commentCount: 2,
  authorName: '홍길동',
  createdAt: DateTime(2026, 3, 1, 10),
  updatedAt: DateTime(2026, 3, 1, 10),
);

final testCommunityComment = CommunityComment(
  id: 'dd0e8400-e29b-41d4-a716-446655440011',
  postId: 'cc0e8400-e29b-41d4-a716-446655440010',
  authorId: '550e8400-e29b-41d4-a716-446655440099',
  content: '아스트록스 88D 추천합니다!',
  likeCount: 1,
  authorName: '김사장',
  createdAt: DateTime(2026, 3, 1, 11),
);

final testCommunityReply = CommunityComment(
  id: 'dd0e8400-e29b-41d4-a716-446655440012',
  postId: 'cc0e8400-e29b-41d4-a716-446655440010',
  authorId: '550e8400-e29b-41d4-a716-446655440000',
  parentId: 'dd0e8400-e29b-41d4-a716-446655440011',
  content: '감사합니다! 참고할게요.',
  authorName: '홍길동',
  createdAt: DateTime(2026, 3, 1, 12),
);

final testCommunityReport = CommunityReport(
  id: 'ee0e8400-e29b-41d4-a716-446655440013',
  reporterId: '550e8400-e29b-41d4-a716-446655440000',
  postId: 'cc0e8400-e29b-41d4-a716-446655440010',
  reason: '부적절한 내용',
  status: ReportStatus.pending,
  createdAt: DateTime(2026, 3, 1, 13),
);
