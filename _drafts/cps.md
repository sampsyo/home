JavaScript is all about events...

    var button = document.querySelector('button');
    button.addEventListener('click', e => {
      alert("hi");
    });

It makes sense to use callbacks everywhere because the system has to run your code later, when something happens.
The neat thing about Node is that it embraces this callbacky structure for *everything* to get a concurrency model based on events...

    const fs = require('fs');
    fs.readFile('cps1.js', (err, data) => {
      console.log(data.length);
    });

But taken to its logical extreme:

    const fs = require('fs');
    fs.stat('cps1.js', (_, stat1) => {
      if (stat1.isFile()) {
        fs.readFile('cps1.js', (_, data1) => {
          fs.stat('cps2.js', (_, stat2) => {
            if (stat2.isFile()) {
              fs.readFile('cps2.js', (_, data2) => {
                console.log(data1.length + data2.length);
              });
            }
          });
        });
      }
    });

This is "callback hell." This code has a *lot* of indentation, but what we really wanted is something much more straight-line, like this:

    stat1 = fs.stat(...);
    if (stat1.isFile()) {
      data1 = fs.readFile(...);
      stat2 = fs.stat(...);
      if (stat2.isFile()) {
        data2 = fs.readFile(...);
        console.log(...);
      }
    }

Can we automatically go from this simplified program to the above?

---

Let's simplify it down and replace fancy IO with simple callback functions.
We can rewrite a simple arithmetic expression `(4 + 2) * 7`, or more verbosely `mul(add(4, 2), 7)`, as:

    function add(a, b, k) {
      k(a + b);
    }
    function mul(a, b, k) {
      k(a * b);
    }

    add(4, 2, s => {
      mul(s, 7, p => {
        console.log(p);
      });
    });

`k` is the callback or *continuation* (for some reason *kontinuation*).
