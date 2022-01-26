λ(bgImageUrlOpt : Optional Text) →
λ(body : Text) →
  let bgImageUrl =
        merge
          { None = "https://media.giphy.com/media/l46Cnk4ZRTlfeI32o/giphy.gif"
          , Some = λ(url : Text) → url
          }
          bgImageUrlOpt

  in  ''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <link rel="stylesheet" type="text/css" href="/style.css" />
          <script src="/index.js" type="text/javascript" charset="utf-8"></script>
          <style>
            body {
              background-image: url('${bgImageUrl}');
            }
          </style>
        </head>
        <body>
          ${body}
        </body>
      </html>
      ''
