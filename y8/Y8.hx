package y8;

import y8.js.Y8JS;

class Y8 {
    public static function init(appId:String, gameId:String, authCallback:Bool->String->Void):Void Y8JS.init(appId, gameId, authCallback);
    public static function login():Void Y8JS.login();
    public static function logout():Void Y8JS.logout();
    public static function getUser():Dynamic return Y8JS.getUser();
    public static function reloadUser():Void Y8JS.reloadUser();
    public static function getToken():Dynamic return Y8JS.getToken();
    public static function refreshToken():Void Y8JS.refreshToken();
    public static function showAd(pauseGame:Void->Void, resumeGame:Void->Void):Void Y8JS.showAd(pauseGame, resumeGame);
    public static function showRewardAd( pauseGame:Void->Void, resumeGame:Void->Void, onReward:Void->Void, onUnavailable:Void->Void):Void Y8JS.showRewardAd(pauseGame, resumeGame, onReward, onUnavailable);
    public static function getLeaderboards(callback:Dynamic->Void):Void Y8JS.getLeaderboards(callback);
    public static function getScores(table:String, page:Int, perPage:Int, mode:String, highest:Bool, callback:Dynamic->Void):Void Y8JS.getScores(table, page, perPage, mode, highest, callback);
    public static function saveScore(table:String, points:Int, allowDuplicates:Bool, highest:Bool):Void Y8JS.saveScore(table, points, allowDuplicates, highest);
    public static function showLeaderboard(table:String, mode:String, highest:Bool):Void Y8JS.showLeaderboard(table, mode, highest);
    public static function getAchievements(callback:Dynamic->Void):Void Y8JS.getAchievements(callback);
    public static function awardAchievement(achievement:String, achievementKey:String, overwrite:Bool, allowDuplicates:Bool):Void Y8JS.awardAchievement( achievement, achievementKey, overwrite, allowDuplicates);
    public static function showAchievements():Void Y8JS.showAchievements();
    public static function saveData(key:String, gameState:Dynamic):Void Y8JS.saveData(key, gameState);
    public static function loadData(key:String, callback:Dynamic->Void):Void Y8JS.loadData(key, callback);
    public static function removeData(key:String):Void Y8JS.removeData(key);
    public static function openProfile():Void Y8JS.openProfile();
    public static function submitImage(picture:String):Void Y8JS.submitImage(picture);
    public static function getLocale(callback:String->Void):Void Y8JS.getLocale(callback);
    public static function checkBlacklist(callback:Bool->Void):Void Y8JS.checkBlacklist(callback);
}
