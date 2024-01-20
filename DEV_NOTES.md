# Developer Notes

## Keeping Tools Updated

All at once with brew upgrade, or provide just the name or names of those you want to upgrade.

```shell
brew update
brew upgrade
brew upgrade periphery powershell swiftformat-for-xcode
```

## Formatting and Linting

```
swiftformat Sources/GrandArt --config .swiftformat
swiftlint --fix --config .swiftlint.yml Sources/GrandArt
```

## Periphery

First, build, then run:

```
xcodebuild -scheme GrandArt -destination 'platform=macOS' -derivedDataPath 'DerivedData' clean build

periphery scan --skip-build --index-store-path 'DerivedData/GrandArt/Index.noindex/DataStore/'
```


