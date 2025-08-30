//
//  FirebaseService.swift (Debug Version with Detailed Logging)
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

    // 🔑 確保 Boss 和 Employee 使用相同的識別碼
    private let currentCompanyId = "company_demo_001"
    private let currentUserId = "user_demo_001"

    init() {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        db.settings = settings

        print("🚀 [FirebaseService] Initialized with company_id: \(currentCompanyId)")
    }

    // MARK: - Boss 功能

    /// 發布排休設定 (詳細除錯版)
    func publishVacationSettings(_ settings: VacationSettings) async throws {
        print("📢 [Boss] Starting publishVacationSettings")
        print("   - Input settings: \(settings.targetYear)/\(settings.targetMonth)")
        print("   - Input isPublished: \(settings.isPublished)")
        print("   - Input publishedAt: \(settings.publishedAt?.description ?? "nil")")

        let firebaseSettings = settings.toFirebaseVacationSettings(companyId: currentCompanyId)

        print("📢 [Boss] Converted to Firebase settings:")
        print("   - targetYear: \(firebaseSettings.targetYear)")
        print("   - targetMonth: \(firebaseSettings.targetMonth)")
        print("   - isPublished: \(firebaseSettings.isPublished)")
        print("   - publishedAt: \(firebaseSettings.publishedAt?.dateValue().description ?? "nil")")
        print("   - companyId: \(firebaseSettings.companyId)")

        // 簡化查詢：只用 company_id 查詢，然後在客戶端過濾
        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: currentCompanyId)

        let snapshot = try await query.getDocuments()
        print("   - Found \(snapshot.documents.count) existing settings documents")

        // 檢查現有文檔
        for (index, doc) in snapshot.documents.enumerated() {
            do {
                let existingData = try doc.data(as: FirebaseVacationSettings.self)
                print("   - Document \(index): \(existingData.targetYear)/\(existingData.targetMonth) (published: \(existingData.isPublished))")
            } catch {
                print("   - Document \(index): Failed to decode - \(error)")
            }
        }

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

            // 🔥 直接更新必要欄位，而不是使用 merge
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
        do {
            let query = db.collection("vacation_settings")
                .whereField("company_id", isEqualTo: currentCompanyId)

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
        print("🚫 [Boss] Unpublishing vacation settings for \(year)/\(month)")

        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: currentCompanyId)

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
        print("📋 [Service] Getting vacation settings for \(year)/\(month)")

        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: currentCompanyId)

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
        print("📝 [Boss] Getting vacation requests for \(year)/\(month)")

        // 簡化查詢：只用 company_id
        let query = db.collection("vacation_requests")
            .whereField("company_id", isEqualTo: currentCompanyId)

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
                // 跳過有問題的文檔，不讓它影響整個載入過程
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
        print("✏️ [Boss] Reviewing request \(requestId) -> \(status)")
        try await db.collection("vacation_requests").document(requestId).updateData([
            "status": status,
            "reviewed_at": Timestamp(),
            "reviewed_by": currentUserId,
            "updated_at": Timestamp()
        ])
        print("✅ [Boss] Successfully updated request status")
    }

    // MARK: - Employee 功能

    /// 提交排休申請
    func submitVacationRequest(
        employeeName: String,
        employeeId: String,
        year: Int,
        month: Int,
        vacationDates: Set<YearMonthDay>,
        note: String
    ) async throws {
        let dateStrings = vacationDates.map { date in
            String(format: "%04d-%02d-%02d", date.year, date.month, date.day)
        }

        print("📤 [Employee] Submitting vacation request:")
        print("   - Employee: \(employeeName) (\(employeeId))")
        print("   - Period: \(year)/\(month)")
        print("   - Dates: \(dateStrings.joined(separator: ", "))")
        print("   - Note: \(note)")
        print("   - Company ID: \(currentCompanyId)")
        print("   - User ID: \(currentUserId)")

        let request = FirebaseVacationRequest(
            companyId: currentCompanyId,
            userId: currentUserId,
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
        print("📝 [Employee] Getting my vacation requests for \(year)/\(month)")

        // 簡化查詢：只用 company_id 和 user_id
        let query = db.collection("vacation_requests")
            .whereField("company_id", isEqualTo: currentCompanyId)
            .whereField("user_id", isEqualTo: currentUserId)

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
                // 跳過有問題的文檔
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
        print("🔍 [Employee] Checking if vacation is published for \(year)/\(month)")

        // 🔥 修復：直接查詢所有設定，不先過濾 is_published
        let query = db.collection("vacation_settings")
            .whereField("company_id", isEqualTo: currentCompanyId)

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

    // MARK: - 工具方法

    /// 獲取排休申請文檔 ID
    private func getVacationRequestId(
        employeeId: String,
        year: Int,
        month: Int
    ) async throws -> String? {
        print("🔍 [Service] Getting request ID for employee \(employeeId) in \(year)/\(month)")

        let query = db.collection("vacation_requests")
            .whereField("company_id", isEqualTo: currentCompanyId)
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
        print("✏️ [Service] Updating request \(requestId) -> \(status)")
        try await db.collection("vacation_requests").document(requestId).updateData([
            "status": status,
            "reviewed_at": Timestamp(),
            "reviewed_by": currentUserId,
            "updated_at": Timestamp()
        ])
        print("✅ [Service] Successfully updated request status")
    }

    // MARK: - 除錯工具

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
        print("🔧 [Debug] Force publishing vacation for \(year)/\(month)")

        do {
            let query = db.collection("vacation_settings")
                .whereField("company_id", isEqualTo: currentCompanyId)

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

// MARK: - Error Handling Extensions
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
