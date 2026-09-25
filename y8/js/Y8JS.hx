package y8.js;

import haxe.Json;
import js.Browser;
import js.html.Event;
import y8.Y8BannerPlacement;

class Y8JS {
    private static var sdk:Dynamic = null;
    private static var initializationRequested:Bool = false;
    private static var authCallback:Bool->String->Void = null;
    private static var appId:String;
    private static var gameId:String;

    public static function init( newAppId:String, newGameId:String, callback:Bool->String->Void):Void {
        appId = newAppId;
        gameId = newGameId;
        authCallback = callback;
        if (initializationRequested) return;
        initializationRequested = true;
        var window:Dynamic = Browser.window;
        Browser.window.addEventListener("y8sdk.ready", function(e:Event):Void onSDKReady(), { once: true });
        if (window.y8 != null && window.y8.emitReadyEvent != null) window.y8.emitReadyEvent();
    }

    private static function onSDKReady():Void {
        var window:Dynamic = Browser.window;
        if (window.y8 == null) { trace("Y8 SDK global object not found"); return; }
        sdk = window.y8.sdk();
        var appConfig:Dynamic = { appId: appId, autoLogin: true };
        var adConfig:Dynamic = {
            gameId: gameId, test: true, preloadAdBreaks: "auto", sound: "on",
            onReady: function():Void trace("Y8 Ads ready")
        };
        sdk.init(appConfig, adConfig);
        sdk.onAuth(function(user:Dynamic, error:Dynamic):Void {
            if (error != null || user == null) {
                if (error != null) trace(error);
                if (authCallback != null) authCallback(false, "");
                return;
            }
            var username = user.nickname != null ? Std.string(user.nickname) : "Player";
            if (authCallback != null) authCallback(true, username);
        });
    }

    public static function login():Void { if (isReady()) sdk.login(); }
    public static function logout():Void { if (isReady()) sdk.logout(); }
    public static function getUser():Dynamic { if (!isReady()) return null; var v = sdk.getUser(); trace("Token: " + v); return v; }
    public static function reloadUser():Void { if (isReady()) sdk.reloadUser().then(function(v){trace("User reloaded successfully");},function(e){trace("Failed to reload user:");trace(e);}); }
    public static function getToken():Dynamic { if (!isReady()) return null; var v = sdk.getToken(); trace("Token: " + v); return v; }
    public static function refreshToken():Void { if (isReady()) sdk.refreshToken().then(function(v){trace("Token refreshed successfully");},function(e){trace("Failed to refresh token:");trace(e);}); }
    public static function showAd(pauseGame:Void->Void, resumeGame:Void->Void):Void {
        if (!isReady()) return;
        sdk.showAd({
            type:"start", name:"start-game",
            beforeAd:function() {trace("beforeAd"); if (pauseGame != null) pauseGame();},
            afterAd:function() trace("afterAd"),
            beforeReward:function(showAdFn:Dynamic) showAdFn(),
            adDismissed:function() trace("adDismissed"),
            adViewed:function() trace("adViewed"),
            adBreakDone:function(info:Dynamic) {trace(info); if (resumeGame != null) resumeGame();}
        }).then(function(v) {}, function(e) { trace(e); if (resumeGame != null)  resumeGame();});
    }

    public static function showRewardAd(pauseGame:Void->Void, resumeGame:Void->Void, onReward:Void->Void, onUnavailable:Void->Void):Void {
        if (!isReady()) return;
        sdk.showAd({
            type:"reward", name:"reward-ad",
            beforeReward:function(showAdFn:Dynamic) { if (pauseGame != null) {pauseGame();} showAdFn();},
            adViewed:function() { trace("Reward ad viewed"); if (onReward != null) onReward();},
            adDismissed:function() trace("Reward ad skipped"),
            adBreakDone:function(info:Dynamic) { trace(info); if (resumeGame != null) {resumeGame();} if (info != null && info.breakStatus != null) { var status:String = Std.string(info.breakStatus); trace("Reward ad break status: " + status); if (status == "other" || status == "frequencyCapped" || status == "noAdPreloaded"){ if (onUnavailable != null) onUnavailable();}}}
        }).then(function(v) {trace(v);}, function(e) { trace(e); if (onUnavailable != null) onUnavailable();});
    }

    public static function getLeaderboards(callback:Dynamic->Void):Void
    {
        if (!isReady()) {
            if (callback != null)
                callback(null);
            return;
        }

        sdk.getLeaderboards().then(
            function(v) {
                trace("Leaderboards: " + haxe.Json.stringify(v, null, "  "));

                if (callback != null)
                    callback(v);
            },
            function(e) {
                trace("Failed to get leaderboards:");
                trace(e);

                if (callback != null)
                    callback(null);
            }
        );
    }

    public static function getScores(
        table:String,
        page:Int = 1,
        perPage:Int = 10,
        mode:String = "alltime",
        highest:Bool = true,
        callback:Dynamic->Void
    ):Void {
        if (!isReady()) {
            if (callback != null)
                callback(null);
            return;
        }
        sdk.getLeaderboardScores({
            table: table,
            page: page,
            perPage: perPage,
            mode: mode,
            highest: highest
        }).then(
            function(v) {
                trace("Leaderboard scores: " + haxe.Json.stringify(v, null, "  "));

                if (callback != null)
                    callback(v);
            },
            function(e) {
                trace("Failed to get leaderboard scores:");
                trace(e);

                if (callback != null)
                    callback(null);
            }
        );
    }
    public static function saveScore(table:String, points:Int, allowDuplicates:Bool = false, highest:Bool = true):Void {
        if (isReady()) sdk.saveLeaderboardScore({table:table,points:points,allowDuplicates:allowDuplicates,highest:highest})
            .then(function(v) { trace("Score saved successfully");}, function(e) { trace("Failed to save score:");trace(e);});
    }
    public static function showLeaderboard(table:String, mode:String = "alltime", highest:Bool = true):Void {
        if (isReady()) sdk.showLeaderboard({table:table,mode:mode,highest:highest})
            .then(function(v){trace("Leaderboard opened successfully");},function(e){trace("Failed to open leaderboard:");trace(e);});
    }

    public static function getAchievements(callback:Dynamic->Void):Void
    {
        if (!isReady()) {
            if (callback != null)
                callback(null);
            return;
        }

        sdk.getAchievements().then(
            function(v) {
                trace("Achievements: " + haxe.Json.stringify(v, null, "  "));

                if (callback != null)
                    callback(v);
            },
            function(e) {
                trace("Failed to get achievements:");
                trace(e);

                if (callback != null)
                    callback(null);
            }
        );
    }

    public static function awardAchievement(achievement:String, achievementKey:String, overwrite:Bool = false, allowDuplicates:Bool = false):Void {
        if (requireUser()) sdk.awardAchievement({achievement:achievement,achievementKey:achievementKey,overwrite:overwrite,allowDuplicates:allowDuplicates})
            .then(function(v){trace("Achievement awarded successfully: " + achievement);},function(e){trace("Failed to award achievement:");trace(e);});
    }
    public static function showAchievements():Void {
        if (isReady()) sdk.showAchievements().then(function(v){trace("Achievements opened successfully");},function(e){trace("Failed to open achievements:");trace(e);});
    }

    public static function saveData(key:String, gameState:Dynamic):Void {
        if (requireUser()) sdk.saveData({key:key,value:Json.stringify(gameState),retries:true})
            .then(function(v) {trace(v);trace("Game data saved successfully");}, function(e) {trace(e);trace("Failed to save game data:");});
    }
    public static function loadData(key:String, callback:Dynamic->Void):Void {
        if (requireUser()) sdk.loadData({key:key}).then(function(v:Dynamic) {
            if (v != null && v != "")
            {
                 try
                {
                    var gameState:Dynamic = Json.parse(Std.string(v));
                    if (callback != null)
                        callback(gameState);
                }
                catch (e:Dynamic)
                {
                    trace("Failed to parse game data:");
                    trace(e);
                 }
            }
            else
            {
                trace("No saved data found for key: " + key);
            }
        }, function(e) {trace("Failed to load game data:"); trace(e);});
    }
    public static function removeData(key:String):Void {
        if (requireUser()) sdk.removeData({key:key}).then(function(v)  {trace("Game data removed successfully: " + key);}, function(e){trace("Failed to remove game data:"); trace(e);});
    }

    public static function openProfile():Void {
        if (requireUser()) sdk.openProfile().then(function(v){trace("Profile opened successfully");},function(e){trace("Failed to open profile:");trace(e);});
    }
    public static function submitImage(picture:String):Void {
        if (requireUser()) sdk.submitImage({picture:picture}).then(function(v){trace("Image submitted successfully");},function(e){trace("Failed to submit image:");trace(e);});
    }

    public static function getLocale(callback:String->Void):Void
    {
        if (!isReady()) {
            if (callback != null)
                callback(null);
            return;
        }

        sdk.getPlatformLocale().then(
            function(v) {
                var locale:String = v != null ? Std.string(v) : null;

                trace("Platform locale: " + locale);

                if (callback != null)
                    callback(locale);
            },
            function(e) {
                trace("Failed to get platform locale:");
                trace(e);

                if (callback != null)
                    callback(null);
            }
        );
    }

    public static function checkBlacklist(callback:Bool->Void):Void
    {
        if (!isReady()) {
            if (callback != null)
                callback(false);
            return;
        }

        sdk.isBlacklisted().then(
            function(v) {
                var blacklisted:Bool = v == true;

                trace("Blacklisted: " + blacklisted);

                if (callback != null)
                    callback(blacklisted);
            },
            function(e) {
                trace("Failed to check blacklist:");
                trace(e);

                if (callback != null)
                    callback(false);
            }
        );
    }

    // ------------------------------------------------------------------
    // Banners
    //
    // A canvas game has no page element to put a banner in, so each banner gets one: a
    // banner-sized element over the game canvas, centred on the placeholder the game
    // reserves for it. The SDK then fills that element. Sizes: 728x90, 300x250, 320x50,
    // 468x60, 320x100 (the SDK rejects anything else). The SDK paces banners per size, so
    // a request too soon after the last one of that size gets "bannerCooldown".
    // ------------------------------------------------------------------

    private static var bannerSlots:Map<String, Dynamic> = new Map();
    private static var bannerResizeListening:Bool = false;

    /**
     * `callback(null)` once a banner shows, otherwise `callback(errorCode)` with the SDK's
     * code (bannerCooldown, unfilled, invalidSize, notVisible, ...). A rejected request
     * leaves any banner already in this slot where it was.
     */
    public static function requestBanner(id:String, width:Int, height:Int, placement:Y8BannerPlacement, callback:String->Void):Void {
        var done = function(error:String):Void {
            if (error != null) trace("Banner " + id + " (" + width + "x" + height + "): " + error);
            if (callback != null) callback(error);
        };
        if (!isReady() || sdk.requestBanner == null) { done("bannersUnavailable"); return; }
        if (id == null || id == "") { done("missingId"); return; }
        // null when the placeholder isn't on the stage
        if (placement == null) { done("notVisible"); return; }
        if (!validBannerPlacement(placement)) { done("invalidSize"); return; }
        var canvas:Dynamic = Browser.document.querySelector("canvas");
        if (canvas == null) { done("notVisible"); return; }

        var box = bannerLayout(canvas, placement, width, height);
        if (box.cssWidth + 1 < width || box.cssHeight + 1 < height) {
            trace("The placeholder is " + Math.round(box.cssWidth) + "x" + Math.round(box.cssHeight)
                + " on screen, smaller than " + width + "x" + height);
            done("invalidSize");
            return;
        }

        var slot:Dynamic = bannerSlots.get(id);
        var previous:Dynamic = slot == null ? null : { width: slot.width, height: slot.height, placement: slot.placement, canvas: slot.canvas };
        if (slot == null) {
            var element = Browser.document.createDivElement();
            element.id = "y8-banner-" + id;
            element.style.cssText = "position:absolute;z-index:2147483000;";
            Browser.document.body.appendChild(element);
            slot = { element: element };
            bannerSlots.set(id, slot);
        }
        slot.width = width;
        slot.height = height;
        slot.placement = placement;
        slot.canvas = canvas;
        placeBanner(slot);
        listenForBannerResize();

        sdk.requestBanner({ id: slot.element.id, width: width, height: height }).then(
            function(v) { done(null); },
            function(e:Dynamic) {
                if (bannerSlots.get(id) == slot) {
                    if (previous != null) {
                        slot.width = previous.width;
                        slot.height = previous.height;
                        slot.placement = previous.placement;
                        slot.canvas = previous.canvas;
                        placeBanner(slot);
                    } else {
                        removeBannerSlot(id);
                    }
                }
                done(e != null && e.code != null ? Std.string(e.code) : "other");
            }
        );
    }

    /** Follows the placeholder when the game moves it; no new ad is requested. */
    public static function moveBanner(id:String, placement:Y8BannerPlacement):Void {
        var slot:Dynamic = bannerSlots.get(id);
        if (slot == null || !validBannerPlacement(placement)) return;
        slot.placement = placement;
        placeBanner(slot);
    }

    public static function clearBanner(id:String):Void {
        if (!bannerSlots.exists(id)) return;
        if (sdk != null) sdk.clearBanner("y8-banner-" + id);
        removeBannerSlot(id);
    }

    public static function clearAllBanners():Void {
        if (sdk != null && sdk.clearAllBanners != null) sdk.clearAllBanners();
        for (id in [for (key in bannerSlots.keys()) key]) removeBannerSlot(id);
    }

    // Where a banner goes, in page CSS pixels, plus the placeholder's size on screen.
    private static function bannerLayout(canvas:Dynamic, p:Y8BannerPlacement, width:Int, height:Int):Dynamic {
        var rect:Dynamic = canvas.getBoundingClientRect();
        var window:Dynamic = Browser.window;
        var scaleX:Float = rect.width / p.areaWidth;
        var scaleY:Float = rect.height / p.areaHeight;
        var cssWidth:Float = p.width * scaleX;
        var cssHeight:Float = p.height * scaleY;
        return {
            left: rect.left + window.scrollX + p.x * scaleX + (cssWidth - width) / 2,
            top: rect.top + window.scrollY + p.y * scaleY + (cssHeight - height) / 2,
            cssWidth: cssWidth,
            cssHeight: cssHeight
        };
    }

    private static function placeBanner(slot:Dynamic):Void {
        var box:Dynamic = bannerLayout(slot.canvas, slot.placement, slot.width, slot.height);
        slot.element.style.left = box.left + "px";
        slot.element.style.top = box.top + "px";
        slot.element.style.width = slot.width + "px";
        slot.element.style.height = slot.height + "px";
    }

    private static function listenForBannerResize():Void {
        if (bannerResizeListening) return;
        bannerResizeListening = true;
        Browser.window.addEventListener("resize", function(e:Event):Void {
            for (slot in bannerSlots) placeBanner(slot);
        });
    }

    private static function validBannerPlacement(p:Y8BannerPlacement):Bool {
        return p != null && Math.isFinite(p.x) && Math.isFinite(p.y)
            && p.width > 0 && p.height > 0 && p.areaWidth > 0 && p.areaHeight > 0;
    }

    private static function removeBannerSlot(id:String):Void {
        var slot:Dynamic = bannerSlots.get(id);
        if (slot == null) return;
        bannerSlots.remove(id);
        slot.element.remove();
    }

    private static function isReady():Bool {
        if (sdk == null) { trace("Y8 SDK not ready"); return false; }
        return true;
    }
    private static function requireUser():Bool {
        if (!isReady()) return false;
        if (sdk.getUser() == null) { trace("User not logged in"); return false; }
        return true;
    }
}
