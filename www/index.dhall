let layout = ./layout.dhall

let addToSlack =
      ./addToSlack.dhall
        env:SPOINTS_SLACK_CLIENT_ID as Text
        env:SPOINTS_SLACK_SCOPE as Text

in  layout
      (None Text)
      ''
      <h1>
        <img height="120" src="https://i.imgur.com/DwNdAae.png" class="spiderman-spin-ccw" />
        Spiderman Points!!!!
        <img height="120" src="https://i.imgur.com/DwNdAae.png" class="spiderman-spin-cw" />
      </h1>
      <h3>
        <img height="80" src="https://i.imgur.com/DwNdAae.png" class="spiderman-spin-cw" />
        You know you want them!!
        <img height="80" src="https://i.imgur.com/DwNdAae.png" class="spiderman-spin-ccw" />
      </h3>
      <div style="margin-top: 150px;">
        ${addToSlack}
      </div>
      <p class="pitch">
        You give your friends Spiderman Points. Your friends give you spiderman points.<br/>
        Everyone's happy! It's great.
      </p>
      <h3>
        <img height="80" src="https://i.imgur.com/DwNdAae.png" class="spiderman-spin-cw" />
        How, you say?
        <img height="80" src="https://i.imgur.com/DwNdAae.png" class="spiderman-spin-ccw" />
      </h3>
      <p>It's simple, just use the slash command to tell your friends how much you appreciate them!</p>
      <img alt="Example usage" width="600" src="https://i.imgur.com/3EXJumD.png" />
      <p>So what are you waiting for?? Mash the "Add to Slack" button!!!!</p>
      ${addToSlack}
      <p>
        <a href="https://github.com/awseward/spiderman-points">
          Check out the source on GitHub!
        </a>
      </p>
      ''
