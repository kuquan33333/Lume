// Targeted Vietnamese String Catalog guard for CI.
// Run from repository root: swift Scripts/check-vi-localization.swift
import Foundation

let files = [
    "Lume/Localizable.xcstrings",
    "Lume/InfoPlist.xcstrings",
    "LumeWidgets/Localizable.xcstrings",
]
let placeholderRE = try! NSRegularExpression(pattern: "%(?:[0-9]+\\$)?(?:lld|ld|@|d|f|s|%)")

func placeholders(in text: String) -> [String] {
    let range = NSRange(text.startIndex..<text.endIndex, in: text)
    return placeholderRE.matches(in: text, range: range).compactMap {
        Range($0.range, in: text).map { String(text[$0]) }
    }.sorted()
}

var errors: [String] = []
for path in files {
    guard
        let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
        let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let strings = root["strings"] as? [String: Any]
    else {
        errors.append("\(path): can't read catalog")
        continue
    }
    var translated = 0
    for (key, raw) in strings where !key.isEmpty {
        guard let item = raw as? [String: Any] else { continue }
        if item["shouldTranslate"] as? Bool == false { continue }
        guard
            let localizations = item["localizations"] as? [String: Any],
            let vi = localizations["vi"] as? [String: Any],
            let stringUnit = vi["stringUnit"] as? [String: Any],
            let translation = stringUnit["value"] as? String,
            !translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            errors.append("\(path): missing Vietnamese: \(key)")
            continue
        }
        translated += 1
        if placeholders(in: key) != placeholders(in: translation) {
            errors.append("\(path): format placeholders differ: \(key)")
        }
    }
    print("\(path): \(translated) Vietnamese entries")
}
if !errors.isEmpty {
    errors.forEach { fputs("error: \($0)\n", stderr) }
    exit(1)
}
print("Vietnamese localization validation passed")
