import Foundation

public final class AuthApiClient: AuthRepository {
    private let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    public func login(request: LoginRequest) async -> LoginResult {
        let url = baseURL.appendingPathComponent("api/auth/login")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "email": request.email,
            "password": request.password
        ]

        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(message: "サーバーエラーが発生しました")
            }

            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            switch httpResponse.statusCode {
            case 200:
                guard let token = json?["token"] as? String,
                      let displayName = json?["displayName"] as? String else {
                    return .failure(message: "レスポンス形式が不正です")
                }
                return .success(token: token, displayName: displayName)
            case 401:
                let error = json?["error"] as? String ?? "認証に失敗しました"
                return .failure(message: error)
            default:
                let error = json?["error"] as? String ?? "サーバーエラーが発生しました"
                return .failure(message: error)
            }
        } catch {
            return .failure(message: "ネットワークエラーが発生しました")
        }
    }
}
