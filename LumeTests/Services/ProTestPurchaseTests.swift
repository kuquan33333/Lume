// Only active in the isolated PRO_TEST sideload configuration.
// The normal StoreKit 2 purchase implementation remains untouched.
#if PRO_TEST && SIDE_LOAD
@testable import Lume
import Testing

@MainActor
struct ProTestPurchaseTests {
    @Test func simulatedMonthlyAndLifetimePurchases() {
        let premium = PremiumManager.shared
        premium.resetTestPlan()
        #expect(!premium.isPremium)

        premium.purchaseTestPlan(.monthly)
        #expect(premium.isPremium)
        #expect(premium.testPurchasedPlan == .monthly)
        #expect(!premium.owns(.monthly)) // Never claim an Apple transaction.

        premium.restoreTestPlan()
        #expect(premium.testPurchasedPlan == .monthly)

        premium.resetTestPlan()
        #expect(!premium.isPremium)
        #expect(premium.testPurchasedPlan == nil)

        premium.purchaseTestPlan(.lifetime)
        #expect(premium.isPremium)
        #expect(premium.testPurchasedPlan == .lifetime)

        premium.resetTestPlan()
    }

    @Test func retiredProductCannotBePurchasedInTestMode() {
        let premium = PremiumManager.shared
        premium.resetTestPlan()
        premium.purchaseTestPlan(.retiredMonthly)
        #expect(!premium.isPremium)
        #expect(premium.testPurchasedPlan == nil)
    }
}
#endif
