pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.components
import qs.config
import qs.utils

Scope {
    id: root

    readonly property bool locked: session.locked
    property string pending: ""

    signal authFailed(string text)

    function screens(on: bool): void {
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.dpms({ action = "${on ? "enable" : "disable"}" })`]);
    }

    IpcHandler {
        target: "lock"

        function lock(): void {
            if (!session.locked)
                session.locked = true;
        }
    }

    PamContext {
        id: pam
        config: "quickshell-lock"

        onPamMessage: {
            if (responseRequired)
                respond(root.pending);
        }

        onCompleted: result => {
            root.pending = "";
            if (result === PamResult.Success) {
                session.locked = false;
                return;
            }
            root.authFailed(result === PamResult.Failed ? "Wrong password, try again" : "Authentication error, try again");
        }
    }

    IdleMonitor {
        enabled: session.locked
        timeout: Config.lockBlankTimeout
        respectInhibitors: false
        onIsIdleChanged: root.screens(!isIdle)
    }

    WlSessionLock {
        id: session

        onLockedChanged: {
            if (!locked) {
                pam.abort();
                root.screens(true);
            }
        }

        WlSessionLockSurface {
            id: surface

            readonly property bool main: surface.screen === ScreenUtils.primaryScreen

            color: "transparent"

            WallpaperBackdrop {
                anchors.fill: parent
            }

            Loader {
                id: panelLoader
                anchors.centerIn: parent
                active: surface.main

                sourceComponent: LoginPanel {
                    id: panel
                    busy: pam.active
                    focus: true
                    onSubmitted: password => {
                        root.pending = password;
                        pam.start();
                    }
                    Component.onCompleted: focusInput()

                    Connections {
                        target: root

                        function onAuthFailed(text) {
                            panel.fail(text);
                        }
                    }
                }
            }
        }
    }
}
