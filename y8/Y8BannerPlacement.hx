package y8;

/**
 * Where a banner goes: the placeholder rectangle the game reserves for it, in the game's
 * own coordinates, measured in a game area of `areaWidth` x `areaHeight` that covers the
 * whole canvas. For OpenFL that area is the stage (`stage.stageWidth` x `stage.stageHeight`);
 * `Y8.requestBannerFor` fills it in from a display object.
 */
typedef Y8BannerPlacement = {
    var x:Float;
    var y:Float;
    var width:Float;
    var height:Float;
    var areaWidth:Float;
    var areaHeight:Float;
}
