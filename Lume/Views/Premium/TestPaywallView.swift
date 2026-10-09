// Isolated checkout for an unsigned Sideloadly QA build.
// Not compiled into real-purchase or regular sideload builds.
#if PRO_TEST && SIDE_LOAD
import SwiftUI

struct TestPaywallView: View {
    let highlight: PremiumFeature?
    @State private var premium = PremiumManager.shared
    @State private var selectedPlan: PremiumManager.Plan?
    @Environment(\.dismiss) private var dismiss

    private var features: [PremiumFeature] {
        guard let highlight else { return PremiumFeature.available }
        return [highlight] + PremiumFeature.available.filter { $0 != highlight }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "crown")
                        .font(.system(size: 44))
                        .foregroundStyle(.tint)
                    Text("Unlock Lume Pro")
                        .font(.title.bold())
                    Text("Lume is free and open source. Pro supports development and unlocks a few extra conveniences.")
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(features) { feature in
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: feature.systemImage)
                                    .font(.title3)
                                    .foregroundStyle(.tint)
                                    .frame(width: 30)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(feature.title).font(.headline)
                                    Text(feature.subtitle)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer(minLength: 0)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("TEST MODE — NO REAL PAYMENT")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.orange)
                        .accessibilityAddTraits(.isHeader)

                    VStack(spacing: 12) {
                        ForEach(PremiumManager.Plan.purchasable, id: \.self) { plan in
                            Button { selectedPlan = plan } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        Group {
                                            if plan == .monthly {
                                                Text("Monthly")
                                            } else {
                                                Text("Lifetime")
                                            }
                                        }
                                        .fontWeight(.semibold)
                                        Group {
                                            if plan == .monthly {
                                                Text("Billed monthly, cancel anytime")
                                            } else {
                                                Text("One-time purchase")
                                            }
                                        }
                                        .font(.caption)
                                    }
                                    Spacer()
                                    Text(plan == .monthly ? "$0.99" : "$9.99")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }
                    }

                    Text("Prices are for illustration only. This test build never charges your Apple Account or creates a subscription.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: 540)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Lume Pro")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Restore") { premium.restoreTestPlan() }
                }
            }
            .onChange(of: premium.isPremium) { _, unlocked in
                if unlocked { dismiss() }
            }
            .alert(
                "Confirm Test Purchase",
                isPresented: Binding(
                    get: { selectedPlan != nil },
                    set: { if !$0 { selectedPlan = nil } }
                )
            ) {
                Button("Unlock Pro (No Charge)") {
                    if let selectedPlan { premium.purchaseTestPlan(selectedPlan) }
                    selectedPlan = nil
                }
                Button("Cancel", role: .cancel) { selectedPlan = nil }
            } message: {
                Text("This is a simulated purchase. No real payment, Apple charge or subscription will occur.")
            }
        }
    }
}
#endif
