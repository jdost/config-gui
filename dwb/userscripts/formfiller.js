#!javascript

/*
 * Formfiller-gpg
 *
 * Formfiller that automatically fills html forms. To get form names the
 * webinspector can be used (needs 'enable-developer-extras' to be enabled.)
 *
 * Configuration:
 *    file: points at the gpg encrypted file (default is
 *      $XDG_CONFIG_HOME/dwb/creds.gpg)
 * */

var leader = ",f",
  forms = null,
  file = data.configDir + "/creds.gpg";

var injectFunction = function (data, submit) {
  var name, value;
  var e;
  for (name in data) {
    if (data.hasOwnProperty(name)) {
      value = data[name];
      e = document.getElementsByName(name)[0];
      if(e.type === "checkbox" || e.type === "radio") {
        e.checked=(value.toLowerCase() !== 'false' && value !== '0');
      } else {
        e.value=value;
      }
    }
  }

  if (submit) {
    e.form.submit();
  }
};

function fillForm () {
  if (forms === null) {
    // if a form object has not been loaded in, will prompt for a pin and spawn the
    // system action to decrypt the file and parse it
    var error,
      master,
      decryptionHandler = function (raw) {
        try {
          forms = JSON.parse(raw);
          fillForm();
        } catch (e) {
          io.error("JSON failed to parse.");
          io.print("[JSON.parse error] " + e.message, "stderr");
        }

        return true;
      };

    master = io.prompt('Enter master password:', false);
    error = system.spawn("gpg --passphrase \"" + master + "\" --batch -d "
        + file, decryptionHandler);

    return;
  }

  var key, r, name, i, l;
  var uri = tabs.current.uri;
  for (key in forms) {
    if (forms.hasOwnProperty(key)) {
      r = new RegExp(key);
      if (r.test(uri)) {
        var script = "(" + String(injectFunction) + ")("
          + JSON.stringify(forms[key].form) + "," +  forms[key].submit + ");";
        var frames = tabs.current.allFrames;
        for (i = 0, l = frames.length; i < l; i++) {
          frames[i].inject(script);
        }
        return;
      }
    }
  }
  io.error("No form entry for the current URL");
}

// leader is just whatever the userscript leads with (default is ',f')
bind(leader + "f", fillForm, "fillform"); // so ',ff' will fill the form
bind(leader + "c", function () { forms = null; }, "clearforms"); // and ',fc' clears
  // the form filling dictionary


// vim: set ft=javascript:
