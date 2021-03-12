'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "4b6db237b3514a88107a422469adfb0f",
"index.html": "200cc667fee3720d0530296c0f547644",
"/": "200cc667fee3720d0530296c0f547644",
"main.dart.js": "bcd39bcfa9e9f67379e33a801002c8cc",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "15f73b7e8a8209c2206210b3ac8dea1b",
".git/config": "38881ccff4dc4e249623736f3cd97a15",
".git/objects/0c/51d825f33fff3c43489add503809086fe0e82c": "9e29129538698774f58d1a2494e1791f",
".git/objects/3e/a5a9fb7408bda12fb3eb0230bf24e5e12696e0": "9cddd7517cb97ae75d245a1516736b5e",
".git/objects/50/cd774b29d4a9a080f9e3d782b7c671e96c3d38": "0df89511688cfabaecdfea391282f71c",
".git/objects/68/9c1389f36ba4e589134b77ae592a84ef6897a1": "d4cf6d1e774b59b9153f884b3802ec3f",
".git/objects/3b/7bb14aa1491eee5f09b6a6f8e93c9c065b1a4c": "4eb339efda754679cbdb45a4b6933e07",
".git/objects/3b/ee79489a28ca2d062b11922a089a7c809aa648": "a70ed4e0f5db335c66be1dd6482f51df",
".git/objects/35/63e7347be1ef18a3a447df1cd5d049cc088e14": "410c839ec94204d5a12c81538aae3317",
".git/objects/0b/88b22a3dcfd1999e6451ee8acd9c488491f51e": "26d29d938d91114afff917ddc8303286",
".git/objects/93/7b33bd85c3c4e7f92ff054110c82537b8ef9a2": "a72ad9ead703d9793f28b02c155d2f6a",
".git/objects/33/0c523a1d037e2e1446cd5d69a4f513eb3bca7a": "c15b7e2dbb4950a1d4e4e54abf25b20c",
".git/objects/a4/12dd9386f28a78753897dbd04f7fc625a905db": "c3a04564a65950c798588f53585395f1",
".git/objects/be/ee07dd04ad10bfb033b7b0bf7e879746da1d66": "aa4f5a26cfafc143396e5837919355f6",
".git/objects/be/3b71d95ae7e09acc34e48a4d44315414718524": "131980569e30958b04fb2171abdcd208",
".git/objects/b3/07ae8c72d3c3b7f2f573cb6c37ee1bae341033": "253dd5b095a1408ae6b01ecee046c7a6",
".git/objects/bc/6f1d57f8843a31354077c4759b2d9960cc0757": "e818611f6640b8d4fcdfe405318b85b6",
".git/objects/e5/951dfb943474a56e611d9923405cd06c2dd28d": "c6fa51103d8db5478e1a43a661f6c68d",
".git/objects/c7/90e045bfef5a65717c0a794781478f7e3b138b": "c867fe9ce2b283e2314e1e55c5539d54",
".git/objects/f2/5787c93ad00665f0f797a43ab397f0628a273e": "59e425d1456034072d902c75d18ec75f",
".git/objects/cf/1c1abe04547ec9b556ed44a012b7f34c875215": "1065578c3e56d17c1ca55fef841bc49d",
".git/objects/ca/7bce8f1454a4bf135837daffd9f26bb93fe676": "40e0e5a1a0e1960f039a738dcf61d792",
".git/objects/fe/62ead26d30d5ec37a25d6074445b7712b8a6f7": "b21341041c8ff6d748d0d60595d9f6fc",
".git/objects/ed/188124ed3e3b950e291d90823b3fbc93243ae8": "77312b294daa110fbb96a49c989ad418",
".git/objects/ec/bd02dfc3638e98a4828642cf5b7c03b03cd280": "c8cc069a4a20b2084cafd1e500e93c6b",
".git/objects/ec/31138d41e812cc93320c0647775a80c78cec07": "a04d11819c78b6698742dd1eb808454e",
".git/objects/20/5bb5db271c6d8de8399864c7bb9b917f638893": "c993b22f115d7f3ae6d5b7b212806539",
".git/objects/18/ef3fb76eb7febe5b08b6386cc6de5919e538ba": "20a0dd869671f8d2e474eea6aa2731cc",
".git/objects/11/8dd809685d52f6146a2538a68d3daf0af37fb8": "8578a9fe90eb618174331f66f745eb5a",
".git/objects/80/8b8fac631af7ecf09687113d717f722a6392fe": "129346359ad80c4fec3dfb60fa0ba4d0",
".git/objects/74/63869afe5c57b4d4155cf83a00c2b606c4bb23": "f88fe249e8d9a3699c4b6968cea28bbb",
".git/objects/8f/03af41b7ea32c739e704e674ebb7b427d549d7": "8f56ecd059d8dd82c37ce39ac9d4ee5a",
".git/objects/8a/aa46ac1ae21512746f852a42ba87e4165dfdd1": "1d8820d345e38b30de033aa4b5a23e7b",
".git/objects/19/782e7e4fa939bafff9e3a84e45dd9f657e9f1d": "c4047d6558ec996a189d03f9a4af6754",
".git/objects/21/c9f052c1363db308990bc5af6f5fe8172b65fb": "20ac946899309305b9b0baa1271834fb",
".git/objects/72/e6ad4768fca6ae00ec5be15967f11336befe47": "a45eddfe0795221254f531f3de0925de",
".git/objects/44/3c42f37a563ef611a65b8013cd753d2cf91159": "4db7c084ef090527e62d2594b6e083fb",
".git/objects/88/cfd48dff1169879ba46840804b412fe02fefd6": "e42aaae6a4cbfbc9f6326f1fa9e3380c",
".git/objects/9f/f4b29df34f2c6f09360e96e13ed89cfb532db8": "203f7ea2e271914e2846fb1b080ca23d",
".git/objects/6b/f12e7853a14a362bdb4e24b846c35333590e7f": "5d0fc1cf7bf6eb28f3fa40d95bd9bcf6",
".git/objects/91/a2a44fd31e05a9e439b630cff6b253ec9cb033": "e4aa50b272aa1613f11fa04cd11cb98f",
".git/objects/91/f2a65d2154b5e2d3ebfc68e3c2969cefd09ca1": "97d06da5edb246c3db525a7b5dfceebc",
".git/objects/08/7819947ab9d32dc5497bcb5e1a23c4f2783928": "3a5aa562ee824232792c68096c1560b0",
".git/objects/52/6be56c0354e6a353ba6d31ddfa137e45b33830": "61c984a861c15358085f29ef04eda254",
".git/objects/55/1c7e738a332b926e1917d110b23458dafdb676": "4b72490801f38fc17d8cde11a224917c",
".git/objects/97/d001e3889aecb0ba32bb1b712e0bb5eec29767": "277faa97535cc7cecba6633d19a3e79a",
".git/objects/63/edc45aea8232f5e9c6c8df03de1edf5d5d3bd9": "e94d8e07e13b06051778f6bebe83deb7",
".git/objects/64/50399d1c2ab36f22254794ca7dd200354f61ba": "c114af8aa65348a05d7ee526f0b18381",
".git/objects/64/0b327ed1ece34adfd43ac45a051234f80170c2": "2856fe0f3d360965ff524f2fd3076014",
".git/objects/ba/6062065b9e76306913f0396b1ee18ca3c59cc7": "58112142d01765ebd32cde4168964672",
".git/objects/b1/057277b8fff2010615771ac25e23c8b7f20974": "570d535e0b7aab91f2ac6dcd9336b367",
".git/objects/b7/49bfef07473333cf1dd31e9eed89862a5d52aa": "36b4020dca303986cad10924774fb5dc",
".git/objects/b7/39678d767f79d293f31b29c2534f75e2a6e73f": "49bdba80da4c4bfab7bf639da9770dc4",
".git/objects/a8/548392e46ce10bd1627947201262231afa24c4": "8499ef6d2897025d4357819b2f1359e0",
".git/objects/a8/3a17d54b6dc2156c855c6580301cefc9c8d017": "6525101be8d70b808a809af9c83fa4ad",
".git/objects/a6/4e3f57baa3219730c2ea6721f637429de6ff9a": "621e92dd8166a23e47a0da0d2d8297bb",
".git/objects/a1/aaed0968fa9747bb1294d8beb13ef3bf54f4a7": "0d5fa1c499b49c8be2887f40fd27b6b3",
".git/objects/a1/3837a12450aceaa5c8e807c32e781831d67a8f": "bfe4910ea01eb3d69e9520c3b42a0adf",
".git/objects/a1/0bbf9576154ff39bb9f2c51fc348bcca5bcc3b": "1d15e69aefdea67dc1f3b00731271e54",
".git/objects/c3/3f28409d8329beed81fe13171f059c04a4f53d": "1908a27a2496d77907efd9051280a2c9",
".git/objects/e1/f63ca5296d5973573ec92419398904ad5d3beb": "0b4a6c561b294b0c380e4c77ffa2ecea",
".git/objects/c5/51d4c9378a9306a2349c539428166f660703f5": "7504f6a0bce5c3dbd645bb2c9e8f06f4",
".git/objects/79/ba7ea0836b93b3f178067bcd0a0945dbc26b3f": "f3e31aec622d6cf63f619aa3a6023103",
".git/objects/70/8a37606ac82846ea545c49c951f1eaadf1108c": "b09ea9bfbb6a2968f78238a82d2ec9f8",
".git/objects/1e/fad6601dd6095466598d77ed9f2d9a134cc32a": "e1581e6304ce3b50a88f3e79de349b94",
".git/objects/8c/012917dab71a26d535ff8c614582477a123a6d": "22939eff7a0cb1fc6bb53c9bf363b949",
".git/objects/1c/4236dff616f1bcbdd0fdb5b0dab43cf29ce05b": "f8064696d2ca8a9db9c9040ce5276530",
".git/objects/1c/153e8bd145fb85c8bd974f6fd98ae8cb01a7d4": "47fb75d82f09cf9393220ab851c32fdb",
".git/objects/7a/f27ce67e125df391e78fc1968ce33c6d173257": "753236ea26dc1e5acb2eba4db70643e6",
".git/HEAD": "4cf2d64e44205fe628ddd534e1151b58",
".git/info/exclude": "036208b4a1ab4a235d75c181e685e5a3",
".git/logs/HEAD": "d1250141ca02220ec87e2110089d3dc0",
".git/logs/refs/heads/master": "d1250141ca02220ec87e2110089d3dc0",
".git/description": "a0a7c3fff21f2aea3cfa1d0316dd816c",
".git/hooks/commit-msg.sample": "579a3c1e12a1e74a98169175fb913012",
".git/hooks/pre-rebase.sample": "56e45f2bcbc8226d2b4200f7c46371bf",
".git/hooks/pre-commit.sample": "e4db8c12ee125a8a085907b757359ef0",
".git/hooks/applypatch-msg.sample": "ce562e08d8098926a3862fc6e7905199",
".git/hooks/fsmonitor-watchman.sample": "ecbb0cb5ffb7d773cd5b2407b210cc3b",
".git/hooks/pre-receive.sample": "2ad18ec82c20af7b5926ed9cea6aeedd",
".git/hooks/prepare-commit-msg.sample": "2b5c047bdb474555e1787db32b2d2fc5",
".git/hooks/post-update.sample": "2b7ea5cee3c49ff53d41e00785eb974c",
".git/hooks/pre-applypatch.sample": "054f9ffb8bfe04a599751cc757226dda",
".git/hooks/pre-push.sample": "3c5989301dd4b949dfa1f43738a22819",
".git/hooks/update.sample": "517f14b9239689dff8bda3022ebd9004",
".git/refs/heads/master": "9aa92937488515a9dea72f191783d39e",
".git/index": "ed1b195421f6d0886022b95a72ce1ced",
".git/COMMIT_EDITMSG": "45c9eb7fa6e6a781268f8a3b8d62d8b9",
"assets/AssetManifest.json": "03f5dfa8953548fb5e293943dc99b116",
"assets/NOTICES": "0330627574286608032fbe11b27a4e80",
"assets/FontManifest.json": "e276392905fdd5f7bd13c6f17a832255",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "d80ca32233940ebadc5ae5372ccd67f9",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "a126c025bab9a1b4d8ac5534af76a208",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "831eb40a2d76095849ba4aecd4340f19",
"assets/fonts/MaterialIcons-Regular.otf": "1288c9e28052e028aba623321f7826ac",
"assets/assets/fonts/sourceCode/SourceCodePro-LightItalic.ttf": "ac76390ae8518be5c0a0bd1f3b088b4b",
"assets/assets/fonts/sourceCode/SourceCodePro-SemiBold.ttf": "420d3580f5b6e63ba1eabb8555b5f6cf",
"assets/assets/fonts/sourceCode/SourceCodePro-Medium.ttf": "f621c504d70317ff13774e27d643ba21",
"assets/assets/fonts/sourceCode/SourceCodePro-SemiBoldItalic.ttf": "6406c55397f0f20723d6b2c2f6515348",
"assets/assets/fonts/sourceCode/SourceCodePro-MediumItalic.ttf": "0b54cce890a75c2227718eaf473068ba",
"assets/assets/fonts/sourceCode/SourceCodePro-Light.ttf": "a8d6f8bb989fc3c860ad2eeac21f9daa",
"assets/assets/fonts/sourceCode/SourceCodePro-BlackItalic.ttf": "fb68d27992feaf97dab1e5640a6f5812",
"assets/assets/fonts/sourceCode/SourceCodePro-BoldItalic.ttf": "c8066b7adaa839e5f0590da2d34723be",
"assets/assets/fonts/sourceCode/SourceCodePro-Black.ttf": "efa63de0d44af1e7de9e01a4467dd423",
"assets/assets/fonts/sourceCode/SourceCodePro-ExtraLight.ttf": "cba7ccef6b4071f76245cc0c5e659aa9",
"assets/assets/fonts/sourceCode/SourceCodePro-Regular.ttf": "b484b32fcec981a533e3b9694953103b",
"assets/assets/fonts/sourceCode/SourceCodePro-ExtraLightItalic.ttf": "b98dab96118c3500d0e8c3f887fcfb26",
"assets/assets/fonts/sourceCode/SourceCodePro-Italic.ttf": "c088801620ae4d69924da74e879170a9",
"assets/assets/fonts/sourceCode/SourceCodePro-Bold.ttf": "03c11f6b0c0f707075d6483a78824c60"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value + '?revision=' + RESOURCES[value], {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
