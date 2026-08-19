package;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;

import openfl.display.BitmapData;
import openfl.geom.Matrix;
import openfl.utils.ByteArray;

import y8.Y8;

#if js
import js.lib.Uint8Array;
import js.Browser;
#end


class Main extends Sprite
{
    private var buttonWidth:Float = 220;
    private var buttonHeight:Float = 40;

    private var loginButton:Sprite;
    private var logoutButton:Sprite;
    private var welcomeText:TextField;

    private var coins:Int = 0;
    private var score:Int = 0;
    private var level:Int = 1;

    private var gameStateText:TextField;

    private var appId:String = "5ea39283d559303d5320eef4";
    private var gameId:String = "270893";


    public function new()
    {
        super();

        trace("Haxe game started");

        createTitle("Y8 SDK - Haxe Test", 30, 20);

        // Authentication
        createTitle("Authentication", 30, 70);
        createWelcomeText();

        loginButton = createButton("Login", 30, 110, login);
        logoutButton = createButton("Logout", 270, 110, logout);

        loginButton.visible = true;
        logoutButton.visible = false;

        createButton("Get User", 30, 160, getUser);
        createButton("Reload User", 270, 160, reloadUser);
        createButton("Get Token", 30, 210, getToken);
        createButton("Refresh Token", 270, 210, refreshToken);

        // Ads
        createTitle("Ads", 30, 270);

        createButton("Show Ad", 30, 310, showAd);
        createButton("Reward Ad", 270, 310, rewardAd);

        // Leaderboards
        createTitle("Leaderboards", 30, 370);

        createButton("Get Leaderboards", 30, 410, getLeaderboards);
        createButton("Get Scores", 270, 410, getScores);
        createButton("Save Score", 30, 460, saveScore);
        createButton("Show Leaderboard", 270, 460, showLeaderboard);

        // Achievements
        createTitle("Achievements", 530, 70);

        createButton("Get Achievements", 530, 110, getAchievements);
        createButton("Award Achievement", 770, 110, awardAchievement);
        createButton("Show Achievements", 530, 160, showAchievements);

        createTitle("Game State", 30, 520);
        

        createGameStateText();

        createButton("+ Coins", 30, 610, addCoins);
        createButton("+ Score", 270, 610, addScore);
        createButton("+ Level", 530, 610, addLevel);

        // Online Saves
        
        createTitle("Online Saves", 530, 220);

        createButton("Save Data", 530, 260, saveData);
        createButton("Load Data", 770, 260, loadData);
        createButton("Remove Data", 530, 310, removeData);

        // Profile
        createTitle("Profile", 530, 370);

        createButton("Open Profile", 530, 410, openProfile);
        createButton("Submit Image", 770, 410, submitImage);

        // Platform
        createTitle("Platform", 530, 470);

        createButton("Get Locale", 530, 510, getLocale);
        createButton("Check Blacklist", 770, 510, checkBlacklist);

        Y8.init(appId,gameId,updateAuthUI);
    }

    // ============================================================
    // UI
    // ============================================================

    private function createTitle(
        label:String,
        xPos:Float,
        yPos:Float
    ):Void
    {
        var text =
            new TextField();

        text.width = 450;
        text.height = 40;

        text.text = label;

        text.x = xPos;
        text.y = yPos;

        text.selectable =
            false;


        var format =
            new TextFormat();

        format.size =
            24;

        format.color =
            0x000000;

        format.bold =
            true;


        text.defaultTextFormat =
            format;

        text.setTextFormat(
            format
        );


        addChild(
            text
        );
    }


    private function createButton(
        label:String,
        xPos:Float,
        yPos:Float,
        callback:MouseEvent->Void
    ):Sprite
    {
        var button:Sprite = new Sprite();

        button.graphics.beginFill(0x3366CC);

        button.graphics.drawRoundRect(
            0,
            0,
            buttonWidth,
            buttonHeight,
            10,
            10
        );

        button.graphics.endFill();

        button.x = xPos;
        button.y = yPos;

        button.buttonMode = true;
        button.mouseChildren = false;


        var text:TextField = new TextField();

        text.width = buttonWidth;
        text.height = buttonHeight;

        text.text = label;

        text.selectable = false;


        var format:TextFormat = new TextFormat();

        format.size = 17;
        format.color = 0xFFFFFF;
        format.align = "center";


        text.defaultTextFormat = format;

        text.setTextFormat(format);

        text.y = 8;


        button.addChild(text);

        button.addEventListener(
            MouseEvent.CLICK,
            callback
        );

        addChild(button);
        return button;
    }

    private function createWelcomeText():Void
    {
        welcomeText = new TextField();

        welcomeText.width = 460;
        welcomeText.height = 30;

        welcomeText.x = 220;
        welcomeText.y = 75;

        welcomeText.text = "Welcome Guest";
        welcomeText.selectable = false;

        var format:TextFormat = new TextFormat();

        format.size = 18;
        format.color = 0x333333;
        format.bold = true;

        welcomeText.defaultTextFormat = format;
        welcomeText.setTextFormat(format);

        addChild(welcomeText);
    }

    private function updateAuthUI(
        loggedIn:Bool,
        username:String
    ):Void
    {
        if (loggedIn)
        {
            welcomeText.text = "Welcome " + username;

            loginButton.visible = false;
            logoutButton.visible = true;
        }
        else
        {
            welcomeText.text = "Welcome Guest";

            loginButton.visible = true;
            logoutButton.visible = false;
        }
    }


    // ============================================================
    // AUTHENTICATION
    // ============================================================

    private function login(
        event:MouseEvent
    ):Void
    {
        Y8.login();
    }


    private function logout(
        event:MouseEvent
    ):Void
    {
        Y8.logout();
    }


    private function getUser(
        event:MouseEvent
    ):Void
    {
        var user = Y8.getUser();
        trace("User received by game: " + haxe.Json.stringify(user, null, "  "));
    }


    private function reloadUser(
        event:MouseEvent
    ):Void
    {
        Y8.reloadUser();
    }


    private function getToken(
        event:MouseEvent
    ):Void
    {
        var token = Y8.getToken();
        trace("Token received by game: " + haxe.Json.stringify(token, null, "  "));
    }


    private function refreshToken(
        event:MouseEvent
    ):Void
    {
        Y8.refreshToken();
    }


    // ============================================================
    // ADS
    // ============================================================

    private function showAd(
        event:MouseEvent
    ):Void
    {
        Y8.showAd(pauseGame, resumeGame);
    }


    private function rewardAd(
        event:MouseEvent
    ):Void
    {
        Y8.showRewardAd(
            pauseGame,
            resumeGame,
            function():Void
            {
                coins += 100;
                updateGameStateText();
                trace("Reward given! Coins: " + coins);
            },
            function():Void
            {
                trace("No rewarded ads available. Please try again later.");
            }
        );
    }

    private function pauseGame():Void
    {
        trace("Game paused");

        // Add your game pause logic here
    }

    private function resumeGame():Void
    {
        trace("Game resumed");

        // Add your game resume logic here
    }


    // ============================================================
    // LEADERBOARDS
    // ============================================================

    private function getLeaderboards(event:MouseEvent):Void
    {
        Y8.getLeaderboards(function(leaderboards:Dynamic) {
            if (leaderboards == null) {
                trace("Failed to get leaderboards");
                return;
            }

            trace("[Y8] Leaderboards:");
            trace(haxe.Json.stringify(leaderboards, null, "  "));
        });
    }


    private function getScores(
        event:MouseEvent
    ):Void
    {
        Y8.getScores("Leaderboard", 1, 10, "alltime", true, function(scores) {
        if (scores == null) {
            trace("Failed to getScores");
            return;
        }
        trace(haxe.Json.stringify(scores, null, "  "));
    });
    }


    private function saveScore(
        event:MouseEvent
    ):Void
    {
        Y8.saveScore("Leaderboard", score, false, true);
    }


    private function showLeaderboard(
        event:MouseEvent
    ):Void
    {
         Y8.showLeaderboard("level_1", "alltime", true);
    }


    // ============================================================
    // ACHIEVEMENTS
    // ============================================================

    private function getAchievements(event:MouseEvent):Void
    {
        Y8.getAchievements(function(achievements) {
            if (achievements == null) {
                trace("Failed to get achievements");
                return;
            }

            trace("[Y8] Achievements:");
            trace(haxe.Json.stringify(achievements, null, "  "));
        });
    }


    private function awardAchievement(
        event:MouseEvent
    ):Void
    {
        Y8.awardAchievement("Test", "4a0b8931b09968995429", false, false);
    }


    private function showAchievements(
        event:MouseEvent
    ):Void
    {
        Y8.showAchievements();
    }


    // ============================================================
    // ONLINE SAVES
    // ============================================================

    private function saveData(
        event:MouseEvent
    ):Void
    {
        var gameState = {
            coins: coins,
            score: score,
            level: level
        };
         Y8.saveData("save", gameState);
    }


    private function loadData(
        event:MouseEvent
    ):Void
    {
         Y8.loadData("save", function(data:Dynamic)
        {
            if (data != null)
            {
                if (data.coins != null)
                    coins = data.coins;

                if (data.score != null)
                    score = data.score;

                if (data.level != null)
                    level = data.level;

                updateGameStateText();

                trace("Game state loaded");
            }
        });
    }


    private function removeData(
        event:MouseEvent
    ):Void
    {
         Y8.removeData("save");
    }

    private function createGameStateText():Void
    {
        gameStateText = new TextField();
        gameStateText.defaultTextFormat = new TextFormat("_sans", 18, 0x000000);
        gameStateText.x = 30;
        gameStateText.y = 560;
        gameStateText.width = 800;
        gameStateText.height = 40;
        gameStateText.selectable = false;

        addChild(gameStateText);

        updateGameStateText();
    }

    private function updateGameStateText():Void
    {
        gameStateText.text = "Coins: " + coins + " | Score: " + score + " | Level: " + level;
    }

    private function addCoins(event:MouseEvent):Void
    {
        coins += 10;
        updateGameStateText();
    }

    private function addScore(event:MouseEvent):Void
    {
        score += 100;
        updateGameStateText();
    }

    private function addLevel(event:MouseEvent):Void
    {
        level += 1;
        updateGameStateText();
    }


    // ============================================================
    // PROFILE
    // ============================================================

    private function openProfile(
        event:MouseEvent
    ):Void
    {
        Y8.openProfile();
    }


    private function submitImage(
        event:MouseEvent
    ):Void
    {
        #if js

        try
        {
            var width:Int =
                Std.int(
                    stage.stageWidth
                );

            var height:Int =
                Std.int(
                    stage.stageHeight
                );


            var bitmapData =
                new BitmapData(
                    width,
                    height,
                    false,
                    0x000000
                );


            bitmapData.draw(
                stage,
                new Matrix()
            );


            var bytes:ByteArray =
                bitmapData.encode(
                    bitmapData.rect,
                    new openfl.display.PNGEncoderOptions()
                );


            var base64:String =
                bytesToBase64(
                    bytes
                );


            var picture:String =
                "data:image/png;base64," +
                base64;


            trace(
                "Screenshot captured"
            );

            trace(
                "Screenshot length: " +
                picture.length
            );


            Y8.submitImage(
                picture
            );


            bitmapData.dispose();
        }
        catch (error:Dynamic)
        {
            trace(
                "Screenshot capture failed:"
            );

            trace(
                error
            );
        }

        #end
    }


    #if js

    private function bytesToBase64(
        bytes:ByteArray
    ):String
    {
        bytes.position = 0;


        var binary:String =
            "";


        while (
            bytes.bytesAvailable > 0
        )
        {
            binary +=
                String.fromCharCode(
                    bytes.readUnsignedByte()
                );
        }


        return Browser.window.btoa(
            binary
        );
    }

    #end


    // ============================================================
    // PLATFORM
    // ============================================================

    private function getLocale(event:MouseEvent):Void
    {
        Y8.getLocale(function(locale:String) {
            if (locale == null) {
                trace("Failed to get locale");
                return;
            }
            trace("Game locale: " + locale);
        });
    }


    private function checkBlacklist(event:MouseEvent):Void
    {
        Y8.checkBlacklist(function(blacklisted:Bool) {
            trace("Blacklisted: " + blacklisted);

            if (blacklisted) {
                trace("Website is blacklisted");
            }
        });
    }
}