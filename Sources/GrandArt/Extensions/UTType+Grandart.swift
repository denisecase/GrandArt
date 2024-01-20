import UniformTypeIdentifiers

/**
 Extend UTType to include org.bhj.grandart (.grandart) files.
 */
@available(macOS 11.0, *)
extension UTType {
  static let grandartDocType = UTType(importedAs: "org.bhj.grandart")
}
