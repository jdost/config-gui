#!javascript


var SETS = [
    'abcdefghijklmnopqrstuvwxyz',
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
    '0123456789',
    '_-=+!@#$%^&*~,.'
  ];

var leader = ",",
  current = {},
  use_defaults = false;


function genPassword (length) {
  var used = [0, 0, 0, 0],
    i, l, set,
    set_map = [],
    password = "";

  for (i = 0; i < length; i++) {
    set = random(SETS.length);
    used[set]++;
    set_map[i] = set;
  }

  for (i = 0, l = used.length; i < l; i++) {
    if (used[i] === 0) {
      var j = 0;
      while (used[i]) {
        if (used[set_map[j]] > 1) {
          used[set_map[j]]--;
          set_map[j] = i;
          used[i]++;
        }
        j++;
      }
    }
  }

  for (i = 0; i < length; i++) {
    set = set_map[i];
    password += SETS[set][random(SETS[set].length)];
  }

  return password;
}

function random (max) {
  return Math.floor(Math.random()*max);
}

function generatePassword () {
  var length = "";
  if (!use_defaults) {
    length = io.prompt("Enter password length:");
  }

  if (!length.length) {
    length = 18;
  } else {
    length = parseInt(length, 10);
  }

  var password = genPassword(length);
  current[tabs.current.uri] = password;

  var script = "(" + String(injectFunction) + ")(\""
    + password + "\");";

  var frame = tabs.current.focusedFrame;
  frame.inject(script);
}

function exportPasswords () {
  if (isEmptyObject(current)) {
    return;
  }

  var file = "";
  if (!use_defaults) {
    file = io.prompt("Enter file to export to:");
  }

  if (!file.length) {
    file = "generated_keys.json";
  }

  io.write(data.configDir + "/" + file, "w", JSON.stringify(current));
}

function injectFunction (password) {
  var current = document.activeElement;
  current.value = password;
}

function isEmptyObject(obj) {
  var i;

  for (i in obj) {
    if (obj.hasOwnProperty(i)) {
      return false;
    }
  }
  return true;
}
bind(leader + "pw", generatePassword, "genPassword");
bind(leader + "ps", exportPasswords, "exportPasswords");

signals.connect("close", function () {
  use_defaults = true;
  exportPasswords();
  return true;
});
