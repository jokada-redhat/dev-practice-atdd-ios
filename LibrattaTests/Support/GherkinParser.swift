import Foundation

struct Feature {
    let name: String
    let scenarios: [Scenario]
}

struct Scenario {
    let name: String
    let steps: [Step]
    let isBackground: Bool
}

struct Step {
    let keyword: StepKeyword
    let text: String
    let table: [[String: String]]?
}

enum StepKeyword: String {
    case given = "Given"
    case when = "When"
    case then = "Then"
    case and = "And"
    case but = "But"
}

final class GherkinParser {

    static func parse(featureFile url: URL) throws -> Feature {
        let content = try String(contentsOf: url, encoding: .utf8)
        return parse(content: content)
    }

    static func parse(content: String) -> Feature {
        let lines = content.components(separatedBy: .newlines)
        var featureName = ""
        var scenarios: [Scenario] = []
        var currentScenarioName = ""
        var currentSteps: [Step] = []
        var isBackground = false
        var backgroundSteps: [Step] = []
        var inScenario = false
        var collectingTable = false
        var tableHeaders: [String] = []
        var tableRows: [[String: String]] = []

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.hasPrefix("Feature:") {
                featureName = String(trimmed.dropFirst("Feature:".count)).trimmingCharacters(in: .whitespaces)
                continue
            }

            if trimmed.hasPrefix("@") || trimmed.isEmpty || (trimmed.hasPrefix("#")) {
                if trimmed.isEmpty && collectingTable {
                    collectingTable = false
                }
                continue
            }

            if trimmed.hasPrefix("Background:") {
                if inScenario {
                    let scenario = Scenario(name: currentScenarioName, steps: currentSteps, isBackground: false)
                    scenarios.append(scenario)
                }
                isBackground = true
                inScenario = false
                currentSteps = []
                collectingTable = false
                continue
            }

            if trimmed.hasPrefix("Scenario:") || trimmed.hasPrefix("Scenario Outline:") {
                if inScenario {
                    let scenario = Scenario(name: currentScenarioName, steps: currentSteps, isBackground: false)
                    scenarios.append(scenario)
                }
                if isBackground {
                    backgroundSteps = currentSteps
                    isBackground = false
                }
                let prefix = trimmed.hasPrefix("Scenario Outline:") ? "Scenario Outline:" : "Scenario:"
                currentScenarioName = String(trimmed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
                currentSteps = backgroundSteps
                inScenario = true
                collectingTable = false
                continue
            }

            if trimmed.hasPrefix("|") {
                let cells = trimmed
                    .split(separator: "|")
                    .map { $0.trimmingCharacters(in: .whitespaces) }

                if !collectingTable {
                    collectingTable = true
                    tableHeaders = cells

                    // Check if it's a key-value table (2 columns, used inline)
                    if cells.count == 2 && !cells[0].isEmpty {
                        tableRows = []
                    } else {
                        tableRows = []
                    }
                } else {
                    if tableHeaders.count == cells.count {
                        var row: [String: String] = [:]
                        for (index, header) in tableHeaders.enumerated() {
                            row[header] = cells[index]
                        }
                        tableRows.append(row)
                    } else if cells.count == 2 {
                        // key-value pair continuation
                        tableRows.append([cells[0]: cells[1]])
                    }
                }
                continue
            }

            // Step line
            if collectingTable {
                // Attach table to previous step
                if !currentSteps.isEmpty {
                    var lastStep = currentSteps.removeLast()
                    let finalTable: [[String: String]]
                    if tableHeaders.count == 2 && tableRows.isEmpty {
                        // Inline key-value: headers are the key-value pair
                        finalTable = [[tableHeaders[0]: tableHeaders[1]]]
                    } else if !tableRows.isEmpty {
                        finalTable = tableRows
                    } else {
                        finalTable = [[tableHeaders[0]: tableHeaders.count > 1 ? tableHeaders[1] : ""]]
                    }
                    lastStep = Step(keyword: lastStep.keyword, text: lastStep.text, table: finalTable)
                    currentSteps.append(lastStep)
                }
                collectingTable = false
                tableHeaders = []
                tableRows = []
            }

            if let keyword = parseKeyword(trimmed) {
                let prefixLen = keyword.rawValue.count
                let text = String(trimmed.dropFirst(prefixLen)).trimmingCharacters(in: .whitespaces)
                let step = Step(keyword: keyword, text: text, table: nil)
                currentSteps.append(step)
            }
        }

        // Finish last scenario
        if collectingTable && !currentSteps.isEmpty {
            var lastStep = currentSteps.removeLast()
            let finalTable: [[String: String]]
            if !tableRows.isEmpty {
                finalTable = tableRows
            } else if tableHeaders.count == 2 {
                finalTable = [[tableHeaders[0]: tableHeaders[1]]]
            } else {
                finalTable = []
            }
            lastStep = Step(keyword: lastStep.keyword, text: lastStep.text, table: finalTable)
            currentSteps.append(lastStep)
        }

        if isBackground {
            backgroundSteps = currentSteps
        } else if inScenario {
            let scenario = Scenario(name: currentScenarioName, steps: currentSteps, isBackground: false)
            scenarios.append(scenario)
        }

        return Feature(name: featureName, scenarios: scenarios)
    }

    private static func parseKeyword(_ line: String) -> StepKeyword? {
        for keyword in [StepKeyword.given, .when, .then, .and, .but] {
            if line.hasPrefix(keyword.rawValue + " ") {
                return keyword
            }
        }
        return nil
    }
}
