import 'package:http/http.dart' as http;
import '../../data/datasources/image_analysis_remote_datasource.dart';
import '../../data/repositories/image_analysis_repository.dart';
import '../../data/repositories/quadratic_repository.dart';
// ❌ убрать: import '../../data/services/mlkit_text_recognition_service.dart';
import '../../data/services/ai_vision_service.dart';
import '../../domain/usecases/solve_quadratic_usecase.dart';
import '../../presentation/providers/quadratic_provider.dart';
import '../../presentation/providers/quadratic_provider_new.dart';
import '../constants/app_constants.dart';

class DependencyInjection {
  static late final SolveQuadraticUseCase _solveQuadraticUseCase;
  static late final ImageAnalysisRepository _imageAnalysisRepository;
  static late final ImageAnalysisRemoteDataSource _imageAnalysisRemoteDataSource;
  // ❌ убрать: static late final MlKitTextRecognitionService _mlKitTextRecognitionService;
  static late final AiVisionService _aiVisionService;
  static late final QuadraticProvider _quadraticProvider;
  static late final QuadraticRepository _quadraticRepository;
  static late final QuadraticProviderNew _quadraticProviderNew;
  static late final http.Client _httpClient;

  static Future<void> init() async {

    _httpClient = http.Client();

    _solveQuadraticUseCase = SolveQuadraticUseCase();

    // ❌ убрать: _mlKitTextRecognitionService = MlKitTextRecognitionService();
    _aiVisionService = AiVisionService(
      httpClient: _httpClient,
      apiKey: AppConstants.aiProviderKey, // DeepSeek ключ
    );

    _imageAnalysisRemoteDataSource = ImageAnalysisRemoteDataSource(
      // ❌ убрать: textRecognitionService: _mlKitTextRecognitionService,
      aiVisionService: _aiVisionService,
    );

    _imageAnalysisRepository = ImageAnalysisRepository(
      _imageAnalysisRemoteDataSource,
    );

    _quadraticRepository = QuadraticRepository(
      solveQuadraticUseCase: _solveQuadraticUseCase,
    );

    _quadraticProvider = QuadraticProvider(
      solveQuadraticUseCase: _solveQuadraticUseCase,
      imageAnalysisRepository: _imageAnalysisRepository,
    );

    _quadraticProviderNew = QuadraticProviderNew(
      repository: _quadraticRepository,
    );
  }

  static SolveQuadraticUseCase get solveQuadraticUseCase => _solveQuadraticUseCase;
  static ImageAnalysisRepository get imageAnalysisRepository => _imageAnalysisRepository;
  static ImageAnalysisRemoteDataSource get imageAnalysisRemoteDataSource => _imageAnalysisRemoteDataSource;
  static QuadraticProvider get quadraticProvider => _quadraticProvider;
  static QuadraticProviderNew get quadraticProviderNew => _quadraticProviderNew;
}

final sl = DependencyInjection;