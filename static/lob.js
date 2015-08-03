function firefox_hack () {  
    if (/Firefox[\/\s](\d+\.\d+)/.test(navigator.userAgent)){  
          var fake_iframe;  
          if (fake_iframe == null){  
              fake_iframe = document.createElement('iframe');  
              fake_iframe.style.display = 'none';  
          }  
          document.body.appendChild(fake_iframe);  
          document.body.removeChild(fake_iframe);  
    }  
} 

function sresp(txt) {
    firefox_hack();
    document.getElementsByTagName("body")[0].innerHTML += txt;
}

function loadif(src, fun){
    var script = document.createElement("iframe");
    script.src = src;
    if(typeof fun === "function"){
        script.onreadystatechange = function() {
            var r = script.readyState;
            console.log(src + ": " + r);
            if (r === 'loaded' || r === 'complete') {
                script.onreadystatechange = null;
                fun();
            }
        };
    }
 
    document.getElementsByTagName("head")[0].appendChild(script);  
}
alert("ok");

// document.addEventListener("DOMContentLoaded", function(){

    var roomid;
    var version = 0;

    function get_name(cb){
        var req = {
            action: "getname"
        }
        Ejoy.postJSON('/lobby', req, function(resp){
            Ejoy('username').html(resp.username);
            roomid = resp.roomid;

            if (cb) {
                cb();
            }
        })

    };

    function join_room(roomid, cb){
        var req = {
            action: "enter",
            roomid: roomid
        }
        Ejoy.postJSON('/room', req, function(resp){
            if (cb) {
                cb();
            }
        })

    };

    function start_poll() {
        loadif('/roompoll', function () {
            start_poll();
        });
        // var req = {
        //     action: "poll",
        //     roomid: roomid,
        //     version:version
        // }
        // Ejoy.postJSON('/room', req, function(resp){
        //     start_poll();
        // })
    }

    get_name(function () {
        join_room(roomid, function() {
            start_poll();
        })
    });
// });
