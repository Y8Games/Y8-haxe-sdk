package y8.js;

import haxe.Json;
import js.Browser;
import js.html.Event;

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
