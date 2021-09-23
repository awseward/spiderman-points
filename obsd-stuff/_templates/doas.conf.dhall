λ(appName : Text) →
  let daemonName = "${appName}d"

  in  ''
      permit nopass ${appName} as root cmd rcctl args restart ${daemonName}
      ''
