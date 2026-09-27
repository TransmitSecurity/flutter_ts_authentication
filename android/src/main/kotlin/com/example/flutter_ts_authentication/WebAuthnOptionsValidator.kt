package com.example.flutter_ts_authentication

/**
 * Validates the WebAuthn option names sent from Dart.
 *
 * A platform-only API on a unified surface. `options` exists **only on iOS**: the native
 * iOS SDK takes a `WebAuthnAuthenticationOptions` OptionSet on `authenticateWebAuthn`,
 * `signWebauthnTransaction` and `approvalWebAuthn`, while the Android SDK's equivalents
 * (`TSAuthentication.authenticateWebAuthn` / `approvalWebAuthn`) declare no such parameter at all.
 *
 * The plugin exposes one cross-platform signature, so it has to decide what Android does with a
 * parameter it cannot forward. The choice made here, on behalf of every integrator:
 *
 *  - **Validate the names anyway**, so an unrecognized option fails identically on both platforms
 *    (`invalidArguments`) instead of being rejected on iOS and accepted on Android. A caller can
 *    then rely on one error contract rather than branching per platform.
 *  - **Then ignore the values**, because there is no native affordance to forward them to. This is
 *    a documented no-op, not a silent drop — see `UserGuide.md`.
 *
 * The alternative — erroring on any non-empty `options` on Android — was rejected: it would make
 * the same correct cross-platform call succeed on iOS and fail on Android, which is worse for a
 * unified surface than a documented no-op.
 *
 * The SDK spells its single option `preferLocalCredantials` (a typo in the native iOS SDK). The
 * plugin accepts the correctly spelled `preferLocalCredentials` as its public contract and also
 * tolerates the SDK's spelling, matching `convertWebAuthnOptions` on the iOS side.
 */
internal object WebAuthnOptionsValidator {

    private val RECOGNIZED_OPTIONS = setOf(
        "preferLocalCredentials",
        "preferLocalCredantials",
    )

    /**
     * Returns `true` when every name in [rawOptions] is recognized. An empty list is valid and
     * means "no options", matching the native iOS default of `[]`.
     */
    fun areValid(rawOptions: List<String>): Boolean =
        rawOptions.all { it in RECOGNIZED_OPTIONS }

    /** The offending names, for an error message that names what was wrong. */
    fun unrecognized(rawOptions: List<String>): List<String> =
        rawOptions.filterNot { it in RECOGNIZED_OPTIONS }
}
