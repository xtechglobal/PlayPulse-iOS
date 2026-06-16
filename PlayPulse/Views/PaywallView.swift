//
//  PaywallView.swift
//  PlayPulse
//
//  Created by Lakhdeep on 16/06/26.
//


import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(SessionViewModel.self) private var session
    @Environment(\.colorScheme) private var colorScheme

    @State private var offerings: Offerings?
    @State private var isLoading: Bool = true
    @State private var isPurchasing: Bool = false
    @State private var isRestoring: Bool = false
    @State private var isPremium: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var selectedPackage: Package?

    var body: some View {
        ZStack {
            backgroundGradient.ignoresSafeArea()

            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.4)
                    Text("Loading plans…")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } else if isPremium {
                premiumActiveView
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        heroSection
                        featuresSection
                        if let offerings, let current = offerings.current {
                            packagesSection(current.availablePackages)
                        }
                        footerSection
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    session.currentScreen = .home
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .alert("Something went wrong", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadData()
        }
    }

    private var heroSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.orange.opacity(0.2), .yellow.opacity(0.15)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "star.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom)
                    )
                    .symbolEffect(.bounce, options: .repeating)
            }

            Text("PlayPulse Premium")
                .font(.system(.largeTitle, design: .rounded, weight: .black))
                .multilineTextAlignment(.center)

            Text("Unlock everything for your\nkid's fitness journey")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 36)
        .padding(.bottom, 28)
        .padding(.horizontal, 24)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            FeatureRow(icon: "infinity", color: .blue, title: "Unlimited Sessions", subtitle: "No caps on daily screen time earning")
            FeatureRow(icon: "chart.bar.xaxis.ascending", color: .green, title: "Advanced Stats", subtitle: "Track progress over weeks & months")
            FeatureRow(icon: "slider.horizontal.3", color: .purple, title: "Custom Exercises", subtitle: "Beyond jumping jacks — more activities")
            FeatureRow(icon: "person.2.fill", color: .orange, title: "Multiple Profiles", subtitle: "Manage all your kids in one place")
            FeatureRow(icon: "nosign", color: .red, title: "Ad-Free Experience", subtitle: "Clean, distraction-free interface")
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private func packagesSection(_ packages: [Package]) -> some View {
        VStack(spacing: 12) {
            Text("Choose Your Plan")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

            ForEach(packages, id: \.identifier) { pkg in
                PackageCard(
                    package: pkg,
                    isSelected: selectedPackage?.identifier == pkg.identifier,
                    onTap: { selectedPackage = pkg }
                )
                .padding(.horizontal, 20)
            }

            Button {
                guard let pkg = selectedPackage ?? packages.first else { return }
                Task { await purchase(pkg) }
            } label: {
                ZStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                            Text("Start Premium")
                                .font(.system(.title3, design: .rounded, weight: .bold))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 18))
            .disabled(isPurchasing || isRestoring)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .onAppear {
                if selectedPackage == nil {
                    selectedPackage = packages.first(where: { $0.identifier == "$rc_annual" }) ?? packages.first
                }
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 10) {
            Button {
                Task { await restore() }
            } label: {
                if isRestoring {
                    ProgressView()
                } else {
                    Text("Restore Purchases")
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(isPurchasing || isRestoring)

            Text("Subscriptions auto-renew. Cancel anytime in App Store settings.\nPrices may vary by region.")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
    }

    private var premiumActiveView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.orange.opacity(0.2), .yellow.opacity(0.15)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                Image(systemName: "crown.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom))
            }
            VStack(spacing: 8) {
                Text("You're Premium!")
                    .font(.system(.largeTitle, design: .rounded, weight: .black))
                Text("All features unlocked. Thanks for your support!")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            Button {
                session.currentScreen = .home
            } label: {
                Text("Continue")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark
                ? [Color(.systemBackground), Color(.systemBackground)]
                : [Color(.systemBackground), Color(.systemGroupedBackground)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func loadData() async {
        isLoading = true
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            isPremium = customerInfo.entitlements["premium"]?.isActive == true
            if !isPremium {
                offerings = try await Purchases.shared.offerings()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }

    private func purchase(_ package: Package) async {
        isPurchasing = true
        do {
            let result = try await Purchases.shared.purchase(package: package)
            isPremium = result.customerInfo.entitlements["premium"]?.isActive == true
        } catch {
            if (error as NSError).code != 1 {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
        isPurchasing = false
    }

    private func restore() async {
        isRestoring = true
        do {
            let info = try await Purchases.shared.restorePurchases()
            isPremium = info.entitlements["premium"]?.isActive == true
            if !isPremium {
                errorMessage = "No active subscriptions found."
                showError = true
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isRestoring = false
    }
}

private struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(.green)
        }
        .padding(14)
        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 14))
    }
}

private struct PackageCard: View {
    let package: Package
    let isSelected: Bool
    let onTap: () -> Void

    private var isAnnual: Bool { package.identifier == "$rc_annual" }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.accentColor : Color(.systemFill), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(package.storeProduct.localizedTitle)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        if isAnnual {
                            Text("BEST VALUE")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.orange, in: Capsule())
                        }
                    }
                    if isAnnual {
                        Text("Save ~58% vs monthly")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.green)
                    } else {
                        Text("Flexible month-to-month")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(package.storeProduct.localizedPriceString)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                    Text(isAnnual ? "/ year" : "/ month")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.accentColor.opacity(0.08) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
