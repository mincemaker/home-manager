pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.modules.common.widgets
import qs.modules.iris.style

MouseArea {
    id: root
    property var usage: ({})

    implicitWidth: grid.implicitWidth
    implicitHeight: grid.implicitHeight
    cursorShape: Qt.PointingHandCursor
    onClicked: fetch.running = true

    function until(ts: var): string {
        if (!ts) return ""
        const m = Math.max(0, Math.round((ts * 1000 - Date.now()) / 60000))
        return m >= 1440 ? `${Math.floor(m / 1440)}d` : m >= 60 ? `${Math.floor(m / 60)}h` : `${m}m`
    }

    Process {
        id: fetch
        command: ["python3", decodeURIComponent(Qt.resolvedUrl("usage.py").toString().replace("file://", ""))]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.usage = JSON.parse(text) } catch (e) {}
            }
        }
    }
    // ponytail: fixed 5-minute poll, Anthropic rate-limits this endpoint so keep it slow
    Timer { interval: 300000; repeat: true; running: true; onTriggered: fetch.running = true }

    GridLayout {
        id: grid
        columns: 3
        columnSpacing: 10 * IrisStyle.density
        rowSpacing: 4 * IrisStyle.density

        Repeater {
            model: [["claude", "Claude"], ["codex", "Codex"]]
            delegate: StyledText {
                required property var modelData
                required property int index
                Layout.row: index
                Layout.column: 0
                text: modelData[1]
                color: IrisStyle.textSecondary
            }
        }
        Repeater {
            model: [["claude", "session", "5h"], ["claude", "week", "7d"], ["codex", "session", "5h"], ["codex", "week", "7d"]]
            delegate: RowLayout {
                id: cell
                required property var modelData
                required property int index
                readonly property var agent: root.usage[modelData[0]] ?? {}
                readonly property var win: agent[modelData[1]] ?? null
                readonly property real pct: win ? win.percent : 0
                Layout.row: Math.floor(index / 2)
                Layout.column: 1 + index % 2
                spacing: 6 * IrisStyle.density

                Rectangle {
                    implicitWidth: 56 * IrisStyle.density
                    implicitHeight: 4 * IrisStyle.density
                    radius: height / 2
                    color: IrisStyle.surfaceHighest
                    Rectangle {
                        width: parent.width * Math.min(1, cell.pct / 100)
                        height: parent.height
                        radius: parent.radius
                        color: cell.pct >= 90 ? "#e5484d" : IrisStyle.accent
                    }
                }
                StyledText {
                    text: cell.agent.error ? "!" : cell.win
                        ? `${cell.modelData[2]} ${Math.round(cell.pct)}% · ${root.until(cell.win.resetsAt)}` : "…"
                    color: IrisStyle.text
                }
            }
        }
    }
}
