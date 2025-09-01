//
//  UserManager.swift
//  ShiftGo
//
//  Updated by Doris Wen on 2025/9/1.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

class UserManager: ObservableObject {
    static let shared = UserManager()

    // MARK: - Published Properties (保持現有 + 新增)
    @AppStorage("userRole") var userRole: String = UserRole.employee.rawValue {
        didSet {
            objectWillChange.send()
        }
    }

    @Published var isLoggedIn: Bool = false
    @Published var isGuest: Bool = false
    @Published var currentUser: User?
    @Published var currentCompany: Company?
    @Published var isLoading = false
    @Published var error: FirebaseError?

    // MARK: - Private Properties
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties (保持現有介面)
    var currentRole: UserRole {
        if let user = currentUser {
            return UserRole(rawValue: user.role) ?? .employee
        }
        return UserRole(rawValue: userRole) ?? .employee
    }

    // MARK: - Initialization
    private init() {
        setupAuthStateListener()
        checkExistingAuth()
    }

    // MARK: - 🔥 保持原有方法 (向後兼容)
    func switchRole() {
        if isGuest {
            userRole = currentRole == .employee ? UserRole.boss.rawValue : UserRole.employee.rawValue
        }
    }

    func logout() {
        do {
            try signOut()
        } catch {
            print("Logout error: \(error)")
        }
    }

    func login(as role: UserRole) {
        userRole = role.rawValue
        isLoggedIn = true
    }

    // MARK: - 🔥 Firebase Authentication Methods

    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                if let user = user {
                    await self?.loadUserData(uid: user.uid)
                } else {
                    self?.clearUserData()
                }
            }
        }
    }

    private func checkExistingAuth() {
        if let user = auth.currentUser {
            Task {
                await loadUserData(uid: user.uid)
            }
        }
    }

    /// 登入
    func signIn(email: String, password: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            Task {
                do {
                    await MainActor.run { self?.isLoading = true }

                    let authResult = try await self?.auth.signIn(withEmail: email, password: password)

                    if let uid = authResult?.user.uid {
                        await self?.loadUserData(uid: uid)
                    }

                    await MainActor.run {
                        self?.isLoading = false
                        self?.isLoggedIn = true
                    }

                    promise(.success(()))
                } catch {
                    await MainActor.run {
                        self?.isLoading = false
                        self?.error = FirebaseError.from(error)
                    }
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// 老闆註冊
    func signUpAsBoss(email: String, password: String, name: String, orgName: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            Task {
                do {
                    await MainActor.run { self?.isLoading = true }

                    // 1. 創建 Firebase 用戶
                    let authResult = try await self?.auth.createUser(withEmail: email, password: password)
                    guard let uid = authResult?.user.uid else { throw FirebaseError.unknown("Failed to create user") }

                    // 2. 創建公司
                    let companyId = try await self?.createCompany(name: orgName, ownerId: uid)
                    guard let companyId = companyId else { throw FirebaseError.unknown("Failed to create company") }

                    // 3. 創建用戶資料
                    let userData: [String: Any] = [
                        "email": email,
                        "name": name,
                        "role": UserRole.boss.rawValue,
                        "company_id": companyId,
                        "employee_id": "BOSS001",
                        "is_active": true,
                        "hourly_rate": 0.0,
                        "employment_type": "full_time",
                        "created_at": Timestamp(),
                        "updated_at": Timestamp()
                    ]

                    try await self?.db.collection("users").document(uid).setData(userData)
                    await self?.loadUserData(uid: uid)

                    await MainActor.run {
                        self?.isLoading = false
                        self?.isLoggedIn = true
                    }

                    promise(.success(()))
                } catch {
                    await MainActor.run {
                        self?.isLoading = false
                        self?.error = FirebaseError.from(error)
                    }
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// 員工註冊
    func signUpAsEmployee(email: String, password: String, name: String, inviteCode: String) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            Task {
                do {
                    await MainActor.run { self?.isLoading = true }

                    // 1. 驗證邀請碼
                    guard let companyId = try await self?.validateInviteCode(inviteCode) else {
                        throw FirebaseError.invalidInviteCode
                    }

                    // 2. 創建 Firebase 用戶
                    let authResult = try await self?.auth.createUser(withEmail: email, password: password)
                    guard let uid = authResult?.user.uid else { throw FirebaseError.unknown("Failed to create user") }

                    // 3. 生成員工編號
                    let employeeId = try await self?.generateEmployeeId(companyId: companyId) ?? "EMP001"

                    // 4. 創建用戶資料
                    let userData: [String: Any] = [
                        "email": email,
                        "name": name,
                        "role": UserRole.employee.rawValue,
                        "company_id": companyId,
                        "employee_id": employeeId,
                        "is_active": true,
                        "hourly_rate": 160.0,
                        "employment_type": "part_time",
                        "created_at": Timestamp(),
                        "updated_at": Timestamp()
                    ]

                    try await self?.db.collection("users").document(uid).setData(userData)
                    await self?.loadUserData(uid: uid)

                    await MainActor.run {
                        self?.isLoading = false
                        self?.isLoggedIn = true
                    }

                    promise(.success(()))
                } catch {
                    await MainActor.run {
                        self?.isLoading = false
                        self?.error = FirebaseError.from(error)
                    }
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// 訪客模式
    func enterGuestMode() -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            Task {
                await MainActor.run {
                    self?.isGuest = true
                    self?.isLoggedIn = true
                    self?.currentUser = User.guestUser()
                    self?.currentCompany = Company.demoCompany()
                    self?.userRole = UserRole.employee.rawValue
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    /// 登出
    func signOut() throws {
        try auth.signOut()
        clearUserData()
    }

    // MARK: - Private Helper Methods

    private func createCompany(name: String, ownerId: String) async throws -> String {
        let inviteCode = generateInviteCode()

        let companyData: [String: Any] = [
            "name": name,
            "owner_id": ownerId,
            "invite_code": inviteCode,
            "max_employees": 50,
            "timezone": "Asia/Taipei",
            "created_at": Timestamp(),
            "updated_at": Timestamp()
        ]

        let docRef = try await db.collection("companies").addDocument(data: companyData)
        return docRef.documentID
    }

    private func validateInviteCode(_ inviteCode: String) async throws -> String? {
        let query = db.collection("companies").whereField("invite_code", isEqualTo: inviteCode)
        let snapshot = try await query.getDocuments()
        return snapshot.documents.first?.documentID
    }

    private func generateEmployeeId(companyId: String) async throws -> String {
        let query = db.collection("users")
            .whereField("company_id", isEqualTo: companyId)
            .whereField("role", isEqualTo: UserRole.employee.rawValue)
        let snapshot = try await query.getDocuments()

        let employeeCount = snapshot.documents.count + 1
        return String(format: "EMP%03d", employeeCount)
    }

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    private func loadUserData(uid: String) async {
        do {
            let userDoc = try await db.collection("users").document(uid).getDocument()

            if let userData = userDoc.data() {
                let user = try User.from(data: userData, uid: uid)

                await MainActor.run {
                    self.currentUser = user
                    self.userRole = user.role
                    self.isLoggedIn = true
                    self.isGuest = false
                }

                // 載入公司資料
                if let companyId = user.companyId {
                    await loadCompanyData(companyId: companyId)
                }
            }
        } catch {
            await MainActor.run {
                self.error = FirebaseError.from(error)
            }
        }
    }

    private func loadCompanyData(companyId: String) async {
        do {
            let companyDoc = try await db.collection("companies").document(companyId).getDocument()

            if let companyData = companyDoc.data() {
                let company = try Company.from(data: companyData, id: companyId)

                await MainActor.run {
                    self.currentCompany = company
                }
            }
        } catch {
            print("載入公司資料失敗: \(error)")
        }
    }

    private func clearUserData() {
        isLoggedIn = false
        isGuest = false
        currentUser = nil
        currentCompany = nil
        userRole = UserRole.employee.rawValue
        error = nil
    }
}
