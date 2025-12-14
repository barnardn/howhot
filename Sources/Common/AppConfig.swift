import Configuration
import Foundation
import SystemPackage

public enum AppConfig {
    public static let defaultConfigFile = "~/.config/howhot.yaml"
    public static let environmentVarPrefix = "howhot"

    public static func configReader(configPath: String = Self.defaultConfigFile) async throws -> ConfigReader {
        let environmentProvider = EnvironmentVariablesProvider()
            .prefixKeys(with: ConfigKey(Self.environmentVarPrefix))

        let configURL = URL(fileURLWithPath: configPath)
        let path = FilePath(stringLiteral: configURL.path())

        let config = try ConfigReader(providers: [
            // prefer values from environment..
            environmentProvider,
            // fall back to configuration file
            await FileProvider<YAMLSnapshot>(filePath: path, allowMissing: true),
        ])
        return config
    }
}
