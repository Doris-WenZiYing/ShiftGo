//
//  FirebaseService.swift
//  ShiftGo
//
//  Created by Doris Wen on 2025/8/30.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    static let shared = FirebaseService()

    // 🔥 修改：動態獲取公司 ID 和用戶 ID，不再使用固定值
    private var currentCompanyId: String? {
        return UserManager.shared.currentCompany?.id
    }

    private var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }

    init() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings

        print("🚀 [FirebaseService] Initialized")
    }

    // MARK: - Boss 功能 (保持現有，但使用動態 ID)

    /// 發布排休設定 (修復版)
    func publishVacationSettings(_ settings: VacationSettings) async throws {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("📢 [Boss] Starting to publish vacation settings for company: \(companyId)")
        print("   - Input settings: \(settings.targetYear)/\(settings.targetMonth)")
        print("   - Input isPublished: \(settings.isPublished)")

        let firebaseSettings = settings.toFirebaseVacationSettings(companyId: companyId)

        print("📢 [Boss] Converted to Firebase settings:")
        print("   - targetYear: \(firebaseSettings.targetYear)")
        print("   - targetMonth: \(firebaseSettings.targetMonth)")
        print("   - isPublished: \(firebaseSettings.isPublished)")
        print("   - companyId: \(firebaseSettings.companyId)")

        // 查詢現有設定
        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: companyId)

        let snapshot = try await query.getDocuments()
        print("   - Found \(snapshot.documents.count) existing settings documents")

        // 在客戶端過濾出匹配的文檔
        let matchingDoc = snapshot.documents.first { doc in
            do {
                let data = try doc.data(as: FirebaseVacationSettings.self)
                let matches = data.targetYear == firebaseSettings.targetYear &&
                             data.targetMonth == firebaseSettings.targetMonth
                if matches {
                    print("   - Found matching document \(doc.documentID) for \(data.targetYear)/\(data.targetMonth)")
                }
                return matches
            } catch {
                print("   - Error checking document \(doc.documentID): \(error)")
                return false
            }
        }

        if let document = matchingDoc {
            print("   - Updating existing document: \(document.documentID)")

            try await document.reference.updateData([
                "is_published": true,
                "published_at": Timestamp(),
                "updated_at": Timestamp(),
                "max_days_per_month": firebaseSettings.maxDaysPerMonth,
                "max_days_per_week": firebaseSettings.maxDaysPerWeek,
                "limit_type": firebaseSettings.limitType,
                "deadline": firebaseSettings.deadline
            ])

            print("✅ [Boss] Successfully updated existing document")

        } else {
            print("   - Creating new document")
            let docRef = try db.collection("vacation_settings").addDocument(from: firebaseSettings)
            print("✅ [Boss] Successfully created new document: \(docRef.documentID)")
        }

        // 驗證更新結果
        print("🔍 [Boss] Verifying update...")
        await verifyPublishStatus(year: firebaseSettings.targetYear, month: firebaseSettings.targetMonth)
    }

    /// 驗證發布狀態（除錯用）
    private func verifyPublishStatus(year: Int, month: Int) async {
        guard let companyId = currentCompanyId else { return }

        do {
            let query = db.collection("vacation_settings")
                .whereField("company_id", isEqualTo: companyId)

            let snapshot = try await query.getDocuments()

            for document in snapshot.documents {
                if let settings = try? document.data(as: FirebaseVacationSettings.self),
                   settings.targetYear == year && settings.targetMonth == month {
                    print("✅ [Boss] Verification - Document \(document.documentID):")
                    print("   - isPublished: \(settings.isPublished)")
                    print("   - publishedAt: \(settings.publishedAt?.dateValue().description ?? "nil")")
                    return
                }
            }
            print("⚠️ [Boss] Verification failed - no matching document found")
        } catch {
            print("❌ [Boss] Verification error: \(error)")
        }
    }

    /// 取消發布排休設定
    func unpublishVacationSettings(year: Int, month: Int) async throws {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("🚫 [Boss] Unpublishing vacation settings for \(year)/\(month)")

        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: companyId)

        let snapshot = try await query.getDocuments()

        // 在客戶端過濾
        for document in snapshot.documents {
            if let data = try? document.data(as: FirebaseVacationSettings.self),
               data.targetYear == year && data.targetMonth == month {
                print("   - Unpublishing document: \(document.documentID)")
                try await document.reference.updateData([
                    "is_published": false,
                    "published_at": FieldValue.delete(),
                    "updated_at": Timestamp()
                ])
            }
        }

        print("✅ [Boss] Successfully unpublished vacation settings")
    }

    /// 獲取排休設定
    func getVacationSettings(year: Int, month: Int) async throws -> VacationSettings? {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("📋 [Service] Getting vacation settings for \(year)/\(month) in company: \(companyId)")

        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: companyId)

        let snapshot = try await query.getDocuments()
        print("   - Found \(snapshot.documents.count) settings documents to check")

        // 在客戶端過濾
        for (index, document) in snapshot.documents.enumerated() {
            do {
                let firebaseSettings = try document.data(as: FirebaseVacationSettings.self)
                print("   - Document \(index) (\(document.documentID)): \(firebaseSettings.targetYear)/\(firebaseSettings.targetMonth) (published: \(firebaseSettings.isPublished))")

                if firebaseSettings.targetYear == year && firebaseSettings.targetMonth == month {
                    print("✅ [Service] Found matching vacation settings")
                    print("   - isPublished: \(firebaseSettings.isPublished)")
                    print("   - publishedAt: \(firebaseSettings.publishedAt?.dateValue().description ?? "nil")")
                    return firebaseSettings.toVacationSettings()
                }
            } catch {
                print("❌ [Service] Failed to decode document \(index): \(error)")
            }
        }

        print("⚠️ [Service] No vacation settings found for \(year)/\(month)")
        return nil
    }

    /// 獲取員工排休申請
    func getVacationRequests(year: Int, month: Int) async throws -> [EmployeeVacation] {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("📝 [Boss] Getting vacation requests for \(year)/\(month) in company: \(companyId)")

        // 查詢該公司的所有排休申請
        let query = db.collection("vacation_requests")
            .whereField("company_id", isEqualTo: companyId)

        let snapshot = try await query.getDocuments()
        print("   - Found \(snapshot.documents.count) request documents to check")

        // 安全的解碼和過濾
        var validRequests: [(FirebaseVacationRequest, Date)] = []

        for (index, document) in snapshot.documents.enumerated() {
            do {
                let firebaseRequest = try document.data(as: FirebaseVacationRequest.self)
                print("   - Document \(index): \(firebaseRequest.employeeName) for \(firebaseRequest.targetYear)/\(firebaseRequest.targetMonth)")

                if firebaseRequest.targetYear == year && firebaseRequest.targetMonth == month {
                    validRequests.append((firebaseRequest, firebaseRequest.createdAt.dateValue()))
                }
            } catch {
                print("❌ [Boss] Failed to decode request document \(index): \(error)")
                continue
            }
        }

        let sortedRequests = validRequests
            .sorted { $0.1 > $1.1 }
            .map { $0.0.toEmployeeVacation() }

        print("✅ [Boss] Successfully loaded \(sortedRequests.count) vacation requests for \(year)/\(month)")
        return sortedRequests
    }

    /// 審核排休申請
    func reviewVacationRequest(requestId: String, status: String) async throws {
        guard let userId = currentUserId else {
            throw FirebaseError.userNotFound
        }

        print("✏️ [Boss] Reviewing request \(requestId) -> \(status)")
        try await db.collection("vacation_requests").document(requestId).updateData([
            "status": status,
            "reviewed_at": Timestamp(),
            "reviewed_by": userId,
            "updated_at": Timestamp()
        ])
        print("✅ [Boss] Successfully updated request status")
    }

    // MARK: - Employee 功能 (保持現有，但使用動態 ID)

    /// 提交排休申請
    func submitVacationRequest(
        employeeName: String,
        employeeId: String,
        year: Int,
        month: Int,
        vacationDates: Set<YearMonthDay>,
        note: String
    ) async throws {
        guard let companyId = currentCompanyId,
              let userId = currentUserId else {
            throw FirebaseError.userNotFound
        }

        let dateStrings = vacationDates.map { date in
            String(format: "%04d-%02d-%02d", date.year, date.month, date.day)
        }

        print("📤 [Employee] Submitting vacation request:")
        print("   - Employee: \(employeeName) (\(employeeId))")
        print("   - Period: \(year)/\(month)")
        print("   - Dates: \(dateStrings.joined(separator: ", "))")
        print("   - Note: \(note)")
        print("   - Company ID: \(companyId)")
        print("   - User ID: \(userId)")

        let request = FirebaseVacationRequest(
            companyId: companyId,
            userId: userId,
            employeeName: employeeName,
            employeeId: employeeId,
            targetYear: year,
            targetMonth: month,
            vacationDates: dateStrings,
            note: note,
            status: "pending",
            submitDate: Timestamp(),
            reviewedAt: nil,
            reviewedBy: nil,
            createdAt: Timestamp(),
            updatedAt: Timestamp()
        )

        let docRef = try db.collection("vacation_requests").addDocument(from: request)
        print("✅ [Employee] Successfully submitted request: \(docRef.documentID)")
    }

    /// 獲取員工自己的排休申請
    func getMyVacationRequests(year: Int, month: Int) async throws -> [EmployeeVacation] {
        guard let companyId = currentCompanyId,
              let userId = currentUserId else {
            throw FirebaseError.userNotFound
        }

        print("📝 [Employee] Getting my vacation requests for \(year)/\(month)")

        // 查詢該用戶的排休申請
        let query = db.collection("vacation_requests")
            .whereField("company_id", isEqualTo: companyId)
            .whereField("user_id", isEqualTo: userId)

        let snapshot = try await query.getDocuments()
        print("   - Found \(snapshot.documents.count) my request documents to check")

        // 安全的解碼和過濾
        var validRequests: [(FirebaseVacationRequest, Date)] = []

        for (index, document) in snapshot.documents.enumerated() {
            do {
                let firebaseRequest = try document.data(as: FirebaseVacationRequest.self)
                print("   - Document \(index): \(firebaseRequest.targetYear)/\(firebaseRequest.targetMonth)")

                if firebaseRequest.targetYear == year && firebaseRequest.targetMonth == month {
                    print("   - Found matching request with dates: \(firebaseRequest.vacationDates.joined(separator: ", "))")
                    validRequests.append((firebaseRequest, firebaseRequest.createdAt.dateValue()))
                }
            } catch {
                print("❌ [Employee] Failed to decode my request document \(index): \(error)")
                continue
            }
        }

        let sortedRequests = validRequests
            .sorted { $0.1 > $1.1 }
            .map { $0.0.toEmployeeVacation() }

        print("✅ [Employee] Successfully loaded \(sortedRequests.count) my vacation requests for \(year)/\(month)")
        return sortedRequests
    }

    /// 檢查排休設定是否已發布 (詳細除錯版)
    func isVacationPublished(year: Int, month: Int) async throws -> Bool {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("🔍 [Employee] Checking if vacation is published for \(year)/\(month) in company: \(companyId)")

        // 直接查詢所有設定，不先過濾 is_published
        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: companyId)

        let snapshot = try await query.getDocuments()
        print("   - Found \(snapshot.documents.count) total settings documents")

        // 在客戶端檢查年月和發布狀態
        for (index, document) in snapshot.documents.enumerated() {
            do {
                let settings = try document.data(as: FirebaseVacationSettings.self)
                print("   - Document \(index) (\(document.documentID)):")
                print("     - Year/Month: \(settings.targetYear)/\(settings.targetMonth)")
                print("     - isPublished: \(settings.isPublished)")
                print("     - publishedAt: \(settings.publishedAt?.dateValue().description ?? "nil")")

                if settings.targetYear == year && settings.targetMonth == month {
                    print("   - ✅ Found matching document!")
                    if settings.isPublished {
                        print("✅ [Employee] Found published vacation for \(year)/\(month)")
                        return true
                    } else {
                        print("⚠️ [Employee] Found matching document but not published")
                        return false
                    }
                }
            } catch {
                print("❌ [Employee] Failed to decode settings document \(index): \(error)")
            }
        }

        print("⚠️ [Employee] No matching vacation settings found for \(year)/\(month)")
        return false
    }

    // MARK: - 🔥 新增：公司和員工管理功能

    /// 創建公司
    func createCompany(name: String, ownerId: String) async throws -> (companyId: String, inviteCode: String) {
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
        print("✅ [Service] Created company: \(docRef.documentID) with invite code: \(inviteCode)")

        return (docRef.documentID, inviteCode)
    }

    /// 驗證邀請碼並返回公司 ID
    func validateInviteCode(_ inviteCode: String) async throws -> String? {
        print("🔍 [Service] Validating invite code: \(inviteCode)")

        let query = db.collection("companies").whereField("invite_code", isEqualTo: inviteCode)
        let snapshot = try await query.getDocuments()

        if let companyDoc = snapshot.documents.first {
            print("✅ [Service] Valid invite code, company ID: \(companyDoc.documentID)")
            return companyDoc.documentID
        } else {
            print("❌ [Service] Invalid invite code")
            return nil
        }
    }

    /// 生成員工編號
    func generateEmployeeId(companyId: String) async throws -> String {
        let query = db.collection("users")
            .whereField("company_id", isEqualTo: companyId)
            .whereField("role", isEqualTo: UserRole.employee.rawValue)
        let snapshot = try await query.getDocuments()

        let employeeCount = snapshot.documents.count + 1
        let employeeId = String(format: "EMP%03d", employeeCount)

        print("📋 [Service] Generated employee ID: \(employeeId) (total employees: \(employeeCount))")
        return employeeId
    }

    /// 獲取公司員工列表 (Boss 功能)
    func getCompanyEmployees() async throws -> [User] {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("👥 [Boss] Getting company employees for: \(companyId)")

        let query = db.collection("users").whereField("company_id", isEqualTo: companyId)
        let snapshot = try await query.getDocuments()

        var employees: [User] = []

        for document in snapshot.documents {
            do {
                let user = try User.from(data: document.data(), uid: document.documentID)
                employees.append(user)
            } catch {
                print("❌ [Boss] Failed to decode employee document \(document.documentID): \(error)")
            }
        }

        print("✅ [Boss] Successfully loaded \(employees.count) employees")
        return employees.sorted { $0.name < $1.name }
    }

    /// 更新員工資料 (Boss 功能)
    func updateEmployee(employeeId: String, updateData: [String: Any]) async throws {
        guard UserManager.shared.currentRole == .boss else {
            throw FirebaseError.permissionDenied
        }

        print("✏️ [Boss] Updating employee: \(employeeId)")

        var data = updateData
        data["updated_at"] = Timestamp()

        try await db.collection("users").document(employeeId).updateData(data)
        print("✅ [Boss] Successfully updated employee")
    }

    // MARK: - 工具方法

    /// 獲取排休申請文檔 ID
    private func getVacationRequestId(
        employeeId: String,
        year: Int,
        month: Int
    ) async throws -> String? {
        guard let companyId = currentCompanyId else {
            throw FirebaseError.invalidCompany
        }

        print("🔍 [Service] Getting request ID for employee \(employeeId) in \(year)/\(month)")

        let query = db.collection("vacation_requests")
            .whereField("company_id", isEqualTo: companyId)
            .whereField("employee_id", isEqualTo: employeeId)

        let snapshot = try await query.getDocuments()

        // 安全的解碼和過濾
        for (index, document) in snapshot.documents.enumerated() {
            do {
                let request = try document.data(as: FirebaseVacationRequest.self)
                if request.targetYear == year && request.targetMonth == month {
                    print("✅ [Service] Found request ID: \(document.documentID)")
                    return document.documentID
                }
            } catch {
                print("❌ [Service] Failed to decode request document \(index): \(error)")
                continue
            }
        }

        print("⚠️ [Service] No request found for employee \(employeeId) in \(year)/\(month)")
        return nil
    }

    /// 更新排休申請狀態
    func updateVacationRequestStatus(
        employeeId: String,
        year: Int,
        month: Int,
        status: EmployeeVacation.VacationRequestStatus
    ) async throws {
        print("✏️ [Service] Updating request status for employee \(employeeId) in \(year)/\(month)")

        guard let documentId = try await getVacationRequestId(
            employeeId: employeeId,
            year: year,
            month: month
        ) else {
            print("❌ [Service] Cannot update - request not found")
            throw FirebaseError.userNotFound
        }

        let statusString: String
        switch status {
        case .pending: statusString = "pending"
        case .approved: statusString = "approved"
        case .rejected: statusString = "rejected"
        }

        try await updateRequestStatus(requestId: documentId, status: statusString)
    }

    /// 內部方法：更新申請狀態
    private func updateRequestStatus(requestId: String, status: String) async throws {
        guard let userId = currentUserId else {
            throw FirebaseError.userNotFound
        }

        print("✏️ [Service] Updating request \(requestId) -> \(status)")
        try await db.collection("vacation_requests").document(requestId).updateData([
            "status": status,
            "reviewed_at": Timestamp(),
            "reviewed_by": userId,
            "updated_at": Timestamp()
        ])
        print("✅ [Service] Successfully updated request status")
    }

    private func generateInviteCode() -> String {
        let chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in chars.randomElement()! })
    }

    // MARK: - 除錯工具 (保持現有)

    /// 列出所有排休設定（除錯用）
    func debugListAllVacationSettings() async {
        print("🐛 [Debug] === Listing all vacation settings ===")
        do {
            let snapshot = try await db.collection("vacation_settings").getDocuments()
            print("   - Total documents: \(snapshot.documents.count)")

            for (index, document) in snapshot.documents.enumerated() {
                do {
                    let settings = try document.data(as: FirebaseVacationSettings.self)
                    print("   - Document \(index) (\(document.documentID)):")
                    print("     - Company: \(settings.companyId)")
                    print("     - Period: \(settings.targetYear)/\(settings.targetMonth)")
                    print("     - Published: \(settings.isPublished)")
                    print("     - PublishedAt: \(settings.publishedAt?.dateValue().description ?? "nil")")
                    print("     - MaxDays: \(settings.maxDaysPerMonth)/month, \(settings.maxDaysPerWeek)/week")
                } catch {
                    print("   - Document \(index) (\(document.documentID)): ❌ Decode error: \(error)")

                    // 顯示原始資料
                    let rawData = document.data()
                    print("     - Raw data: \(rawData)")
                }
            }
        } catch {
            print("❌ [Debug] Failed to list settings: \(error)")
        }
        print("🐛 [Debug] === End of vacation settings ===")
    }

    /// 列出所有排休申請（除錯用）
    func debugListAllVacationRequests() async {
        print("🐛 [Debug] === Listing all vacation requests ===")
        do {
            let snapshot = try await db.collection("vacation_requests").getDocuments()
            print("   - Total documents: \(snapshot.documents.count)")

            for (index, document) in snapshot.documents.enumerated() {
                do {
                    let request = try document.data(as: FirebaseVacationRequest.self)
                    print("   - Document \(index) (\(document.documentID)):")
                    print("     - Employee: \(request.employeeName) (\(request.employeeId))")
                    print("     - Period: \(request.targetYear)/\(request.targetMonth)")
                    print("     - Status: \(request.status)")
                    print("     - Dates: \(request.vacationDates.joined(separator: ", "))")
                } catch {
                    print("   - Document \(index) (\(document.documentID)): ❌ Decode error: \(error)")

                    // 顯示原始資料
                    let rawData = document.data()
                    print("     - Raw data: \(rawData)")
                }
            }
        } catch {
            print("❌ [Debug] Failed to list requests: \(error)")
        }
        print("🐛 [Debug] === End of vacation requests ===")
    }

    /// 強制重新發布（除錯用）
    func debugForcePublish(year: Int, month: Int) async {
        guard let companyId = currentCompanyId else {
            print("❌ [Debug] No current company")
            return
        }

        print("🔧 [Debug] Force publishing vacation for \(year)/\(month)")

        do {
            let query = db.collection("vacation_settings")
                .whereField("company_id", isEqualTo: companyId)

            let snapshot = try await query.getDocuments()

            for document in snapshot.documents {
                if let settings = try? document.data(as: FirebaseVacationSettings.self),
                   settings.targetYear == year && settings.targetMonth == month {

                    print("🔧 [Debug] Force updating document \(document.documentID)")
                    try await document.reference.updateData([
                        "is_published": true,
                        "published_at": Timestamp(),
                        "updated_at": Timestamp()
                    ])
                    print("✅ [Debug] Force publish completed")
                    return
                }
            }

            print("⚠️ [Debug] No document found to force publish")
        } catch {
            print("❌ [Debug] Force publish failed: \(error)")
        }
    }
}

// MARK: - Error Handling Extensions (保持現有)
extension FirebaseService {
    func handleFirebaseError(_ error: Error) -> FirebaseError {
        if let error = error as? FirebaseError {
            return error
        }

        if let firestoreError = error as NSError? {
            switch firestoreError.code {
            case FirestoreErrorCode.permissionDenied.rawValue:
                return .permissionDenied
            case FirestoreErrorCode.notFound.rawValue:
                return .vacationSettingsNotFound
            case FirestoreErrorCode.unavailable.rawValue:
                return .networkError(firestoreError.localizedDescription)
            default:
                return .unknown(firestoreError.localizedDescription)
            }
        }

        return .unknown(error.localizedDescription)
    }
}
