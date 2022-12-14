var rp = rp || {};

var rpChatConfig = rpChatConfig || {};

rpChatConfig.deptId = 94;
rpChatConfig.pagename = '';
rpChatConfig.textLinkCaption = '';

var rp = rp || {};

rp.chat = {

    isInitiated: false,
    inviteEnabled: 1,
    chatWindow: 'default',

    setChatWindow: function(mode) {
    	this.chatWindow = (typeof mode !== 'undefined') ? mode : 'default';
    	
    	return true;
    },
    
    getChatWindow: function() {
    	return this.chatWindow;
    },

    enableInvite: function() {
        clearTimeout(rp.chat.Core.resLoadStatus);
        setTimeout(function(){ startLoadStatus(); }, 7000);

        return true;
    },

    disableInvite: function() {
        this.inviteEnabled = 0;
        rp.chat.Core.hideInvitation();

        return true;
    },

    isInviteEnabled: function() {
        return this.inviteEnabled;
    },
    
    updatedCustomValues: function() {
        if ( typeof rp.chat.Core !== 'undefined' ) {
            rp.chat.Core.loadStatus( 1 );
        }
        return true;
    },
    
    triggerBusinessRuleEvent: function(id, eventName, eventPayload) {
        if (typeof rp.chat.Core !== 'undefined') {
            if (typeof rpChatConfig === 'undefined') {
                rpChatConfig = {};
            }
            rpChatConfig.customValues = rpChatConfig.customValues || {};
            rpChatConfig.customValues.businessRuleEvent = {brEventId:id, brEventName:eventName, brEventPayload:eventPayload };

            rp.chat.Core.loadStatus(1);
        }
        return true;
    },

    enable: function() {
        if (typeof rpChatConfig.enabled === "undefined" || rpChatConfig.enabled === false) {
            rpChatConfig.enabled = true;
            rp.chat.Core.loadConfig();
        }
        return this;
    },

    disable: function() {
        rpChatConfig.enabled = false;
        window.clearTimeout(rp.chat.Core.resLoadStatus);
        rp.chat.Core.removeStatusbutton();
        rp.chat.Core.hideInvitation();
        return this;
    },

    changePage: function(config) {
        if (typeof config !== "undefined") {
            rpChatConfig = config;
        }
        if (typeof rpChatConfig.enabled === "undefined" || rpChatConfig.enabled === true) {
            this.disable().enable();
        } else {
            this.disable();
        }
        return this;
    },

    loadModules: function() {
        if ( typeof navigator.cookieEnabled === "boolean" && !navigator.cookieEnabled ) {
            if ( typeof console !== "undefined" ) {
                console.log( "Cookies aktivieren um den Chat zu nutzen" );
            }
            return;
        }

        rp.chat.isInitiated = true;
        this.Core = new rp.chat.CoreModul();
        this.Chat = new rp.chat.ChatModul();
    },

    loadLayerModul: function(callback) {
    	var config = rp.chat.Core.getConfig();
    	if (!this.LayerChat && config.chatType === 'layer') this.LayerChat = new rp.chat.LayerChatModul();
    	if (!this.LayerChat && config.chatType === 'layer2') this.LayerChat = new rp.chat.LayerChatModuleV2();

    	if( typeof callback === "function" ) {
    		callback();
    	}
    },

    loadAdBlockModul: function () {
        if (typeof rp.chat.AdBlockModul !== 'undefined') {
            this.AdBlock = new rp.chat.AdBlockModul();
        }
    },
    
    loadWebRTCModul: function () {
        if (typeof DetectRTC !== 'undefined') {
            DetectRTC.load(function() {
                if (!(!DetectRTC.isWebRTCSupported || DetectRTC.browser.isIE || DetectRTC.browser.isEdge)) {
                    rp.chat.Core.setWebRTCDetected(1);
                }
            })
        }
    },
    
    loadRpFpModul: function () {

        if (typeof Fingerprint2 !== 'undefined') {
            var fp = new Fingerprint2();
            fp.get(function(rpfp) {
                rp.chat.Core.setFp(rpfp);
            });
        }
    },

    startLoadStatus: function() {
        this.inviteEnabled = 1;
        clearTimeout(rp.chat.Core.resLoadStatus);
        rp.chat.Core.resLoadStatus = setTimeout("rp.chat.Core.loadStatus()", 0);
    },

    checkAvailability: function(callback) {
    	var deptId = rp.chat.Core.getDeptId();
    	var url = rp.chat.Core.getRPDomain('dialog');
    	var jQuery = rp.chat.Core.getJQ();
    	jQuery.getJSON(url + '/rest/v1.0/availability/' + deptId).done(function(data) {
    		if(typeof callback === "function") {
    			callback(data);
    		}
    	});
    }
};

rp.chat.CoreModul = function() {

    prototype: {
        var that = this;

        var urlCollect = document.scripts.realpersonChatLoader.src.substr(0, document.scripts.realpersonChatLoader.src.indexOf("scripts/loadchatmodul")).slice(0, -1);
        var jq = null;
        var config = {};
        var status = {};

        var currentUrl = escape(location.toString());
        var referUrl = escape(document.referrer);
        var sessionrp = '';
        var sidOpti = '';

        var inviteImgIsLoaded = 0;
        var inviteImgRejected = 0;
        var mouseOverInvite = false;
        var adBlockDetected = 0;
        var hasAdBlockDetected = 0;
        var countLoadStatusRequests = 0;
        var webRTCDetected = 0;
        var rpfp = "";

        this.resLoadStatus = null;
        var configLoaded = 0;

        this.getJQ = function() {
            return jq;
        }

        this.getAjaxDataType = function() {
            var domain = (urlCollect.indexOf("://") > -1) ? urlCollect.split('/')[2] : "";
            return (domain === document.domain) ? 'json' : 'jsonp';
        } 

        this.getRPDomain = function(kind) {
            if (typeof kind === "undefined" || kind === "collect") {
                return urlCollect;
            }
            return (config.urlDialog) ? config.urlDialog : "";
        }

        this.startChat = function(invitetyp, kind)
        {
            if (Object.keys(config).length == 0) {
                return false;
            }

            var kindString = "";    
            if (typeof kind == "undefined") {
                kindString = "text";
            } else {
                var pattern = /(video|text)/i;
                if (pattern.test(kind)) {
                    kindString = kind;
                } else {
                    kindString = "text";
                }
            }
            
            var autoinviteRulesId = rp.chat.Chat.getCurrentAutoinviteRulesId(invitetyp);

            // Akanoo autoinvite accept
            if (autoinviteRulesId && window.at && rpChatConfig.customValues && rpChatConfig.customValues.businessRuleEvent && rpChatConfig.customValues.businessRuleEvent.brEventPayload) {
            	window.at('trigger', 'claim', rpChatConfig.customValues.businessRuleEvent.brEventPayload.measure);
            }

            this.hideInvitation();
            isValidCookieOnlineBeratung();
            
            if (typeof config.trackRpFp !== 'undefined' && config.trackRpFp ) {
            	this.setRpFp();
            }
            
            if (config.chatType !== 'layer2' && (typeof config.isMobile !== 'undefined' || rp.chat.getChatWindow() == 'mobile')) {
                
            	rp.chat.Chat.startMobileChat(invitetyp, kindString, config.statusbutton[kindString], autoinviteRulesId);
            	
            } else if ((config.isLayerChat && kindString == 'text' && rp.chat.getChatWindow() == 'default') || rp.chat.getChatWindow() == 'layer') {
            	
                if (!config.statusbutton[kindString].onlinestatus && typeof config.statusbutton[kindString].offlineUrl !== "undefined") {
                	window.open(rp.chat.Core.getRPDomain('dialog') + "/redirect.php?action=offlineurl&session_rp=" + rp.chat.Core.getSessionRp() + "&deptid=" + rp.chat.Core.getDeptId(),'_blank', '');
                	return false;
                }

            	if (config.chatType === 'layer') {
            		rp.chat.Core.loadLayerChatModule(function() {
            			rp.chat.LayerChat.setLayer(invitetyp, kindString, autoinviteRulesId);
            		});
            	}

            	if (config.chatType === 'layer2') {
            		rp.chat.Core.loadLayerChatModuleV2(function() {
            			triggerEvent(document, 'rp-start-chat');
            			rp.chat.LayerChat.setLayer(invitetyp, kindString, autoinviteRulesId);
            		});
            	}
            	
            } else {
            	rp.chat.Chat.startPopupChat(invitetyp, kindString, config, autoinviteRulesId);
            }
            return false;
        }

        this.rejectInvitation = function() {
            this.hideInvitation();

            var request_url = urlCollect + "/scripts/setstatus.php?action=rejectinvitation&deptid=" + rp.chat.Core.getDeptId() + "&pageurl=" + currentUrl + "&session_rp=" + sessionrp;

            jq.ajax({
                dataType: rp.chat.Core.getAjaxDataType(),
                type: 'get',
                cache: false,
                url: request_url,
            }).done(function(data) {
            }).fail(function(XMLHttpRequest, textStatus, errorThrown) {});

            // Akanoo reject
            if (window.at && rpChatConfig.customValues && rpChatConfig.customValues.businessRuleEvent && rpChatConfig.customValues.businessRuleEvent.brEventPayload) {
            	window.at('trigger', 'dismiss', rpChatConfig.customValues.businessRuleEvent.brEventPayload.measure);
            }
            
            return false;
        }

        this.hideInvitation = function() {

            if (typeof status.autoinvite !== 'undefined') {
                this.inviteImgRejected = 1;
                status.autoinvite.show = 0;

                if (status.autoinvite.fade_out == 'up-to-down') {
                    jq('div#InviteLayerRealPersonname').stop();
                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated');
                    jq('div#InviteLayerRealPersonname').animate({ top: jq(document).height() }, "slow", function() { jq('#InviteLayerRealPersonname').remove(); inviteImgRejected = 0;});

                } else if (status.autoinvite.fade_out == 'down-to-up') {
                    jq('div#InviteLayerRealPersonname').stop();
                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated');
                    jq('div#InviteLayerRealPersonname').animate({ top: (0 - jq('div#InviteLayerRealPersonname').height()) }, "slow", function() { jq('#InviteLayerRealPersonname').remove(); inviteImgRejected = 0;});

                } else if (status.autoinvite.fade_out == 'hinge' && animationSupport()) {
                    jq('div#InviteLayerRealPersonname').stop();
                    jq('div#InviteLayerRealPersonname').on('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() { jq('#InviteLayerRealPersonname').remove(); inviteImgRejected = 0; });
                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated realperson-hinge');

                } else if (status.autoinvite.fade_out == 'zoomout' && animationSupport()) {
                    jq('div#InviteLayerRealPersonname').stop();
                    jq('div#InviteLayerRealPersonname').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() { jq('#InviteLayerRealPersonname').remove(); inviteImgRejected = 0; });
                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated realperson-zoomOut');
                } else {
                    jq('#InviteLayerRealPersonname').remove();
                }
                inviteImgIsLoaded = 0;
            } else if (inviteImgRejected == 0) {
                jq('div#InviteLayerRealPersonname').css('display', 'none');
                inviteImgIsLoaded = 0;

                if (jq('#InviteLayerRealPersonname').length > 0) {
                    jq('#InviteLayerRealPersonname').remove();
                }
            }

            mouseOverInvite = false;
        }

        this.removeStatusbutton = function() {
            jq("span#optiRealPersonContent #realperson_text_status_button").remove();
            jq("span#optiRealPersonContent #realperson_video_status_button").remove();
        }

        this.getCurrentUrl = function() {
            return currentUrl;
        }

        this.getDeptId = function() {
            return (typeof rpChatConfig !== "undefined" && typeof rpChatConfig.deptId !== "undefined") ? rpChatConfig.deptId : 0; 
        }

        this.getSessionRp = function() {
            return escape(sessionrp);
        }

        this.getSidOpti = function() {
            return escape(sidOpti);
        }

        this.getCobrowsingUserName = function() {
            if ((typeof status.cobrowsing !== 'undefined') && (status.cobrowsing.user_name)) {
                return status.cobrowsing.user_name;
            }
            return '';
        }

        this.getCobrowsingUserImage = function() {
            if ((typeof status.cobrowsing !== "undefined") && (status.cobrowsing.user_image)) {
                return status.cobrowsing.user_image;
            }
            return '';
        }

        this.getAdBlockDetected = function() {
            return adBlockDetected;
        }
        
        this.getWebRTCDetected = function() {
            return webRTCDetected;
        }
        
        this.setWebRTCDetected = function(value) {
            webRTCDetected = value;
        }
        
        this.getFp = function() {
            return rpfp;
        }
        
        this.setFp = function(rpfp2) {
            rpfp = rpfp2;
        }

        this.getConfig = function() {
        	return config;
        }

        this.getBrowserWidth = function() {
            return (document.body.offsetWidth) ? document.body.offsetWidth : (window.outerWidth) ? window.outerWidth : 0;
        }

        this.getBrowserHeight = function() {
            return (document.body.offsetWidth) ? window.innerHeight : (document.body.offsetHeight) ? document.body.offsetHeight : 0;
        }

        var setConfigLoaded = function(status) {
            configLoaded = status;
        }

        this.loadConfig = function() {
            if (typeof rpChatConfig !== 'undefined' && typeof rpChatConfig.enabled !== 'undefined' && rpChatConfig.enabled == false){
                return;
            }

            if (typeof rpChatConfig === 'undefined') {
                rpChatConfig = {};
            }
            rpChatConfig.enabled = true;

            setConfigLoaded(1);

            jq(document).ready(function() {

            var request_url = urlCollect + "/scripts/loadconfig.php";
            var customValue = {};
            if (typeof rpChatConfig !== 'undefined') {
                customValue = rpChatConfig.customValues || {};
            }

            var params = { 
                deptid: that.getDeptId(), 
                pageurl: currentUrl,
                session_rp: sessionrp, 
                deptlist: getCookieDeptList(), 
                referer: referUrl,
                screen_width: jq(document).width(),
                start_admin_cobrowsing: (new RegExp('[\#]rpcobrowsing=([^&#]*)').exec(window.location.href) !== null) ? (new RegExp('[\#]rpcobrowsing=([^&#]*)').exec(window.location.href))[1] : '',
                customValues: JSON.stringify(customValue)
            }

            jq.ajax({
                dataType: that.getAjaxDataType(),
                type: 'GET',
                cache: false,
                url: request_url,
                data: params,
                success: function(data) {

                    if (typeof data.cobrowsing !== "undefined" && typeof data.cobrowsing.url !== "undefined") {
                        window.location.href = data.cobrowsing.url;
                    }

                    if (typeof data.whitelistblocked !== 'undefined') {
                        return false;
                    }

                    jq.extend(config, data);

                    setCookieSession();
                    transferExtCookieOnlineBeratung();

                    if (typeof config.checkAdBlock !== "undefined" && typeof rp.chat.AdBlock === "undefined") {
                        jq.ajax({
                            url: urlCollect + "/third-party/blockadblock/blockadblock.js",
                            dataType: "script",
                            success: function() {
                                rp.chat.loadAdBlockModul();
                                rp.chat.Core.detectAdBlock();
                            }
                        });
                    }

                    if (typeof DetectRTC === "undefined") {
                        if (typeof config.hasVideoSupport !== "undefined" && config.hasVideoSupport) {
                            jq.ajax({
                                url: urlCollect + "/third-party/webrtc/DetectRTC.min.js",
                                dataType: "script",
                                success: function () {
                                    rp.chat.loadWebRTCModul();
                                }
                            });
                        }
                    }

                    if (typeof config.trackRpFp !== "undefined" && config.trackRpFp) {
                        jq.ajax({
                            url: urlCollect + "/third-party/rpfp/rpfp.min.js",
                            dataType: "script",
                            success: function() {
                            	rp.chat.loadRpFpModul();
                            }
                        });
                    }

                    if (jq("link[href='" + urlCollect + "/css/realperson-code.css']").length == 0) {
                        var link = document.createElement("link");
                        link.type = "text/css";
                        link.rel = "stylesheet";
                        link.href = urlCollect + "/css/realperson-code.css";
                        document.getElementsByTagName("head")[0].appendChild(link);
                    }

                    if (config.theme && jq("link[href='" + urlCollect + "/layouts/" + config.theme + "/css/realperson-code.css']").length == 0) {

                        var link = document.createElement("link");
                        link.type = "text/css";
                        link.rel = "stylesheet";
                        link.href = urlCollect + "/layouts/" + config.theme + "/css/realperson-code.css";
                        document.getElementsByTagName("head")[0].appendChild(link);
                    }

                    if (config.isLayerChat) {
                    	if (config.chatType === 'layer') rp.chat.Core.loadLayerChatModule();
                    	if (config.chatType === 'layer2') rp.chat.Core.loadLayerChatModuleV2();
                    }

                    jq("span#optiRealPersonContent").addClass(config.statusbutton.addClass);

                    if (typeof data.cobrowsing !== 'undefined' && typeof data.cobrowsing.cookieList !== 'undefined') {
                        for (var key in data.cobrowsing.cookieList) {
                            var cookie = data.cobrowsing.cookieList[key];
                            rp.chat.Core.writeCookie(cookie["name"], cookie["content"]);
                            window.document.location.href = data.cobrowsing.url;
                        }
                    }

                    triggerEvent(document,'rp-onlinestatus', {
                        text: !!config.statusbutton.text.onlinestatus,
                        video: !!config.statusbutton.video.onlinestatus
                    });

                    loadStatusbutton('text');
                    loadStatusbutton('video');

                    if (typeof config.businessRule !== "undefined" && typeof config.businessRule.exitIntent !== "undefined") {
                        window.document.addEventListener("mouseout", function(e) {
                            e = e ? e : window.event;
                            var from = e.relatedTarget || e.toElement;
                            if (!from || from.nodeName == "HTML") {
                                if (rp.chat.inviteEnabled === 1) {
                                    rpChatConfig.customValues = rpChatConfig.customValues || {};
                                    rpChatConfig.customValues.customerEvent = { exitIntent: "true" };
                                    rp.chat.startLoadStatus();
                                }
                            }
                        });

                        window.document.addEventListener("mouseover", function() {
                            rpChatConfig.customValues = rpChatConfig.customValues || {};
                            if (typeof rpChatConfig.customValues.customerEvent !== "undefined" && typeof rpChatConfig.customValues.customerEvent.exitIntent !== "undefined") {
                                delete rpChatConfig.customValues.customerEvent.exitIntent;
                            }
                        });
                    }

                    if (typeof config.businessRule !== "undefined" && typeof config.businessRule.scrollDown !== "undefined") {
                        jq(window).scroll(function() {
                            var scrollPos = Math.floor((jq(window).scrollTop() / (jq(document).height() - jq(window).height())) * 100);
                             config.businessRule.scrollDown.forEach(function(element) {
                                if (element.enabled === true && scrollPos >= element.scroll) {
                                    if (rp.chat.Core.resLoadStatus !== null) {
                                        element.enabled = false;
                                        rpChatConfig.customValues = rpChatConfig.customValues || {};
                                        rpChatConfig.customValues.customerEvent = { scrollPosition: element.scroll };
                                        rp.chat.startLoadStatus();
                                    }
                                }
                                if (element.enabled === false && scrollPos < element.scroll) {
                                    element.enabled = true;
                                }
                            });
                         });
                    }

                    rp.chat.Core.loadStatus();
                }
            });
            });
        }

        this.loadLayerChatModule = function(callback) {
            if (typeof rp.chat.LayerChat === "undefined") {
                jq.ajax({
                    url: urlCollect + "/scripts/loadlayerchatmodul.js",
                    dataType: "script",
                    success: function() {
                        rp.chat.loadLayerModul();
                        rp.chat.LayerChat.createLayer(callback);
                    }
                });
            } else {
                rp.chat.LayerChat.createLayer(callback);
            }
        }

        this.loadLayerChatModuleV2 = function(callback) {
            if(typeof rp.chat.LayerChat === 'object') {
                callback();
                return;
            }

            jq.ajax({
                url: urlCollect + "/scripts/loadlayerchatmodul-v2.js",
                dataType: "script",
                success: function() {
                    rp.chat.loadLayerModul(function () {
                        rp.chat.LayerChat.bindEvents();
                        rp.chat.LayerChat.createLayer(callback);
                    });
                }
            });
        }
        this.loadStatus = function( onlySaveStatus ) {
             if ((config.isLayerChat && typeof rp.chat.LayerChat == 'undefined') || (typeof config.checkAdBlock !== "undefined" && !hasAdBlockDetected)) {
                // wenn LayerChat, oder AdBlock ermitteln dann darauf warten das JS-Datei fertig mit laden ist
                this.resLoadStatus = setTimeout("rp.chat.Core.loadStatus()", 2);
                return;
            }

            var isOnlySaveStatus = (typeof onlySaveStatus !== 'undefined');

            var chatLayer = 0;
            if (typeof rp.chat.LayerChat !== 'undefined') {
                chatLayer = rp.chat.LayerChat.getChatLayerIsActive();
            }

            var request_url = urlCollect + "/scripts/loadstatus.php";

            var customValue = {};
            if (typeof rpChatConfig !== 'undefined') {
                customValue = rpChatConfig.customValues || {};
            }

            var coBrowsingUrl = '';
            if (typeof TogetherJS !== 'undefined'){
                coBrowsingUrl = TogetherJS.shareUrl();
            }

            var isInviteEnabled = 1;
            if (typeof rp.chat.LayerChat !== 'undefined' && chatLayer) {
                isInviteEnabled = 0;
            }

            this.resLoadStatus = null;

            var params = {
                deptid: rp.chat.Core.getDeptId(),
                pageurl: currentUrl,
                session_rp: sessionrp,
                inviteEnabled: (rp.chat.inviteEnabled && (tabActive || typeof status.autoinvite != 'undefined')) ? isInviteEnabled : 0,
                chatlayer: chatLayer,
                customValues: JSON.stringify(customValue),
                cobrowsingurl: coBrowsingUrl,
                adblock_detected: adBlockDetected,
                count_status_requests: countLoadStatusRequests
            };

            var that = this;
            jq.ajax({
                dataType: rp.chat.Core.getAjaxDataType(),
                type: 'GET',
                cache: false,
                url: request_url,
                data: params,
                success: function(data) {
                    
                    status = data;

                    // Funktionen aufrufen wenn vorhanden
                    if (typeof data.execute !== 'undefined') {
                        jq.each(data.execute, function(index, value) { eval(value); }); 
                    }

                    checkAutoInviteStatus();
                    if ( isOnlySaveStatus ) return;
                    checkCobrowsingStatus();

                    if (typeof status.checkStatus === 'undefined') {
                        status.checkStatus = 60;
                    }

                    if (status.checkStatus > 0) {
                        that.resLoadStatus = setTimeout("rp.chat.Core.loadStatus()", (status.checkStatus * 1000));
                    }
                },
                error: function() {
                	if ( isOnlySaveStatus ) return;
                    rp.chat.Core.resLoadStatus = setTimeout("rp.chat.Core.loadStatus()", 60000);
                }
            });
            countLoadStatusRequests = countLoadStatusRequests + 1;
        }

        var checkAutoInviteStatus = function() {

            if ((typeof status.autoinvite === 'undefined') || (status.autoinvite.show == 0)) {
                rp.chat.Core.hideInvitation();
                return false;
            }
 
            loadInviteImage();

            if (inviteImgIsLoaded == 0) {
                jq("#InviteImageRealPerson").on('load', function() {
                    inviteImgIsLoaded = 1;
                    checkInviteTye();
                });
            } else {
                checkInviteTye();
            }
        }

        var checkInviteTye = function() {

            if (jq('#InviteLayerRealPersonname').length == 0 || inviteImgRejected) {
                return false;
            }

            inviteStart = 0;

            if (jq('div#InviteLayerRealPersonname').hasClass('hide')) {
                jq('div#InviteLayerRealPersonname').removeClass('hide');
                jq('div#InviteLayerRealPersonname').css('display', 'inline');

                jq('div#InviteLayerRealPersonname').mouseover(function() {
                    if (typeof status.autoinvite !== 'undefined' && status.autoinvite.type == 'slide') { 
                        jq('div#InviteLayerRealPersonname').stop().stop(); 
                        mouseOverInvite = true;
                    } 
                });
                jq('div#InviteLayerRealPersonname').mouseout(function() {
                    if (typeof status.autoinvite !== 'undefined' && status.autoinvite.type == 'slide') { 
                        mouseOverInvite = false;
                        showInviteSlide(0);
                    } 
                });

                inviteStart = 1;
            }

            if (status.autoinvite.type == 'popup') {
                rp.chat.Core.startChat(0);
            } else {
                var left = (jq(document).width() / 2) - (jq('div#InviteLayerRealPersonname').width() / 2);
                var top = 150;

                if (status.autoinvite.fade_in == 'zoomIn' && inviteStart) {
                    jq('div#InviteLayerRealPersonname').css('top', top + 'px');
                    jq('div#InviteLayerRealPersonname').css('left', left + 'px');
                    
                    jq('div#InviteLayerRealPersonname').one('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', function() { showInvite(); });
                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated realperson-zoomIn');

               } else if (status.autoinvite.fade_in == 'down-to-up' && inviteStart) {
                    jq('div#InviteLayerRealPersonname').css('top', jq(document).height() + 'px');
                    jq('div#InviteLayerRealPersonname').css('left', left + 'px');

                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated');
                    jq('div#InviteLayerRealPersonname').animate({ top: top }, "slow", function() { showInvite(); });

                } else if (status.autoinvite.fade_in == 'up-to-down' && inviteStart) {
                    jq('div#InviteLayerRealPersonname').css('top', (0 - jq('div#InviteLayerRealPersonname').height())  + 'px');
                    jq('div#InviteLayerRealPersonname').css('left', left + 'px');

                    jq('div#InviteLayerRealPersonname').addClass('realperson-animated');
                    jq('div#InviteLayerRealPersonname').animate({ top: top }, "slow", function() { showInvite(); });

                } else {
                    showInvite();
                }
            }
        }

        var showInvite = function() {
            inviteImgRejected = 0;
            jq('div#InviteLayerRealPersonname').removeClass('realperson-zoomIn');

            if (status.autoinvite.type == 'slide') {
                showInviteSlide(inviteStart);
            } else if (status.autoinvite.type == 'popup') {
                rp.chat.Core.startChat(0);
            } else if (status.autoinvite.type == 'still-br') {
                showInviteBottomRight();
            } else {
                showInviteCenter();
            }
        }

        var checkCobrowsingStatus = function() {
            if ((typeof status.cobrowsing !== 'undefined') && (status.cobrowsing.load)) {
                if (document.getElementById('realperson-cobrowsingmodul') == null) {
                    var layerJSFile = document.createElement("script");
                    layerJSFile.type = "text/javascript";
                    layerJSFile.id = "realperson-cobrowsingmodul";
                    layerJSFile.src = urlCollect + "/scripts/loadcobrowsingmodul.js";
                    layerJSFile.onload = function() {
                        rp.chat.Cobrowsing = new rp.chat.CobrowsingModul();
                        rp.chat.Cobrowsing.loadLibrary(status.cobrowsing);
                    };
                    document.getElementsByTagName("head")[0].appendChild(layerJSFile);
                }
            }

            if ((typeof status.cobrowsing !== 'undefined') && (status.cobrowsing.refresh)) {
                if ((typeof TogetherJS !== 'undefined')) {
                    TogetherJS.refreshUserData();
                }
            }
        }


        var showInviteSlide = function(start) {

            if (status.autoinvite.type != 'slide') {
                return false;
            }

            var top = 150;
            var left = jq(document).width() - jq('div#InviteLayerRealPersonname').width() - 30;

            if (start && !mouseOverInvite) {
                jq('div#InviteLayerRealPersonname').css('top', top + 'px');
            }

            var speddToRight = status.autoinvite.speed;
            var speedToLeft = (status.autoinvite.speed / left) * jq('div#InviteLayerRealPersonname').offset().left;

            if (jq('div#InviteLayerRealPersonname').is(':not(:animated)') && !mouseOverInvite) { 
                jq('div#InviteLayerRealPersonname').animate({"left": 10}, speedToLeft).animate({"left": left}, speddToRight);
            }
        }

        var showInviteCenter = function() {
            var top = 150;
            var left = (jq(document).width() / 2) - (jq('div#InviteLayerRealPersonname').width() / 2);

            jq('div#InviteLayerRealPersonname').css('top', top + 'px');
            jq('div#InviteLayerRealPersonname').css('left', left + 'px');
        }

        var showInviteBottomRight = function() {
            var bottom = 110;
            var right = 0;

            jq('div#InviteLayerRealPersonname').css('top', 'auto');
            jq('div#InviteLayerRealPersonname').css('bottom', bottom + 'px');
            jq('div#InviteLayerRealPersonname').css('right', right + 'px');
            jq('div#InviteLayerRealPersonname').css('width', 'unset');
        }

        var loadStatusbutton = function(type) {

        	if ( config.statusbutton[type].onlinestatus == 1 ) {
				jq("span#optiRealPersonContent").addClass(type + '-online');
			} else {
				jq("span#optiRealPersonContent").addClass(type + '-offline');
			}

        	if (typeof config.statusbutton[type].src !== 'undefined' || rp.chat.Core.getTextLinkCaption() != "") {
                var div = jq('<div>');
                div.attr('id', 'realperson_' + type + '_status_button');

                if (typeof config.statusbutton[type].animation !== 'undefined') {
                    div.attr('class', 'realperson-animated ' + config.statusbutton[type].animation);
                }

                var link = jq('<a>');
                link.attr('id', 'RealpersonChatStatusButtonLink' + type);
                link.attr('href', "javascript:void(0);");
                link.css('display', 'none');

                if (rp.chat.Core.getTextLinkCaption() != "") {
                    link.text(rp.chat.Core.getTextLinkCaption());
                } else {
                    var img = jq('<img id=\'RealpersonChatStatusButton' +  type + '\'>');
                    img.attr('src', config.statusbutton[type].src);
                    img.attr('title', config.statusbutton[type].infotext);
                    img.attr('alt', config.statusbutton[type].infotext);
                }

                 if (rp.chat.Core.getTextLinkCaption() != "") {
                     jq(div).append(link);
                     jq("span#optiRealPersonContent").append(div);
                } else {
                    if (config.statusbutton[type].onlinestatus || (!config.statusbutton[type].onlinestatus && config.statusbutton[type].offlineClick)) {
                        jq(link).append(img);
                        jq(div).append(link);
                        jq("span#optiRealPersonContent").append(div);

                        jq('#realperson_' + type + '_status_button').bind('click', function(e) {        
                            e.preventDefault();
                            rp.chat.Core.startChat(1, type);
                        });
                    } else {
                        jq(div).append(img);
                        jq("span#optiRealPersonContent").append(div);
                    }
                }
            }
        }

        /** deprecated ? */
        var getCookieSession = function(){
            var content = getCookieContent("REALPERSON_SESSION=");
            return (content != false) ? content : "null";
        };

        var setCookieSession = function() {
            if (!isValidCookieSession()) {
                sessionrp = (typeof config.createSessionRp !== "undefined") ? config.createSessionRp : "";
                document.cookie = "REALPERSON_SESSION=" + sessionrp + "; path=/; domain=" + getFirstDomainName();
            }
        }

        var isValidCookieSession = function() {
            var content = getCookieContent("REALPERSON_SESSION=");
            if (content != false) {
                sessionrp = content;
            }
            return content;
        }


        var setCookieOnlineBeratung = function() {
            var date = new Date();
            date.setTime(date.getTime() + (30 * 24 * 60 * 60 * 1000));

            sidOpti = (new Date()).getTime();

            document.cookie = "ONLINEBERATUNG=" + sidOpti + "%3B" + rp.chat.Core.getDeptId() + "; expires=" + date.toGMTString()+"; path=/; domain=" + getFirstDomainName();
        }

        var updateCookieOnlineBeratung = function() {
            if (typeof config.isDeptNotInCookieGroup !== 'undefined') {
                var firstDomain = getFirstDomainName();
                var cookieContent = getCookieOnlineBeratung();

                var ablauf = new Date();
                var gueltigkeitinTagen = ablauf.getTime() + (30 * 24 * 60 * 60 * 1000);
                ablauf.setTime(gueltigkeitinTagen);

                document.cookie = "ONLINEBERATUNG=" + cookieContent + "%3B" + rp.chat.Core.getDeptId() + "; expires=" + ablauf.toGMTString() + "; path=/; domain=" + firstDomain;
            }
        }

        var getCookieOnlineBeratung = function() {
            return getCookieContent("ONLINEBERATUNG=");
        }

        var getCookieDeptList = function() {
            var content = getCookieOnlineBeratung();
            var deptList = "";

            if (content) {
                if (content.indexOf("%3B") != -1) {
                    deptList = content.substring(16, content.length);
                } else {
                    deptList = content.substring(13, content.length);
                }
            }

            return deptList;
        }

        var transferExtCookieOnlineBeratung = function() {
            var cookieContent = getCookieOnlineBeratung();
            var extCookieContent = (typeof config.extCookieOnlineberatung !== "undefined") ? config.extCookieOnlineberatung : "";
            if (!cookieContent && extCookieContent) {
                var ablauf = new Date();
                var gueltigkeitinTagen = ablauf.getTime() + (30 * 24 * 60 * 60 * 1000);
                ablauf.setTime(gueltigkeitinTagen);
                var firstDomain = getFirstDomainName();
                document.cookie = "ONLINEBERATUNG=" + extCookieContent + "; expires=" + ablauf.toGMTString()+"; path=/; domain=" + firstDomain;
            }
        }

        var isValidCookieOnlineBeratung = function() {
            var content = getCookieOnlineBeratung();
            
            if (!content) {
                setCookieOnlineBeratung();
            } else {
                sidOpti = content.substring(0, 13);

                var deptList = content.substring((content.indexOf("%3B") !== -1 ? 16 : 13), content.length);
                var cookieContentSplit = deptList.split("%3B");

                // Pr??fen ob die DeptID bereits vorhanden ist.
                if (cookieContentSplit.indexOf(rp.chat.Core.getDeptId().toString()) === -1) {
                    updateCookieOnlineBeratung();
                }
            }
        }

        /** deprecated ? */
        var getCookieChatContent = function() {
            var content = getCookieContent("ChatContent=");
            return (content != false) ? content : "null";
        };

        var getCookieContent = function(name) {
            var cookies = document.cookie;
            var startPos = cookies.indexOf(name);

            if (startPos != -1) {
                startPos += name.length;
                var endPos = (cookies.indexOf(";", startPos) != -1) ? cookies.indexOf(";", startPos) : cookies.length;
                var cookie = cookies.substring(startPos, endPos);
                if (cookie != "") {
                    return cookie;
                }
            }
            return false;
        }

        this.getPagename = function() {
            return (typeof rpChatConfig !== "undefined" && typeof rpChatConfig.pagename !== "undefined") ? rpChatConfig.pagename : ""; 
        }

        this.getTextLinkCaption = function() {
            return (typeof rpChatConfig !== "undefined" && typeof rpChatConfig.textLinkCaption !== "undefined") ? rpChatConfig.textLinkCaption : ""; 
        }

        this.getFirstDomainName = function() {
            return getFirstDomainName();
        }

        var getFirstDomainName = function() {
            var host = escape(window.location.hostname.toString()).split(".");

            if (host.length > 3) {
                firstDomain = host[host.length - 3] + "." + host[host.length - 2] + "." + host[host.length - 1];
            } else if (host.length > 1) {
                firstDomain = host[host.length - 2] + "." + host[host.length - 1];
            }

            return escape(firstDomain);
        }

        this.writeCookie = function(name, content) {
            var firstDomain = getFirstDomainName();
            document.cookie = name + "=" + content + "; path=/;";
        }

        var loadInviteImage = function() {

            if ((typeof status.autoinvite !== 'undefined') && (status.autoinvite.img) && (jq('div#InviteLayerRealPersonname').length == 0)) {

                inviteImgIsLoaded = 0;

                var div = jq('<div>');
                div.attr('id', 'InviteLayerRealPersonname');
                div.attr('class', 'realperson_invitelayer hide');
                div.css('display', 'none');
                div.css('top', '0');
                div.css('border', '1px solid transparent');

                if (/MSIE\s([\d.]+)/.test(navigator.userAgent) && parseFloat(navigator.appVersion.split("MSIE")[1]) < 9) {
                    div.css('position', 'absolute'); // bei IE < 9
                } else {
                    div.css('position', 'fixed');
                }

                jq(div).append(status.autoinvite.img);
                jq("body").append(div);

                sendSiteCatalystAutoinviteEvent();
            }
        }

        var sendSiteCatalystAutoinviteEvent = function() {

            if (status.autoinvite.firstevent && (typeof s !== 'undefined')) {
                var c_pagename = c_rulename = c_pagename = c_country = c_shopname = c_deptname = "";

                if (typeof rpChatConfig !== 'undefined' || typeof rpChatConfig.customValues !== 'undefined') {
                    c_pagename = rpChatConfig.customValues.pagename;
                    c_country = rpChatConfig.customValues.country;
                    c_shopname = rpChatConfig.customValues.shopname;
                }

                c_rulename = status.autoinvite.rule_name;
                c_deptname = status.autoinvite.dept;

                s.prop1 = s.eVar2 = c_pagename;
                s.eVar3 = Date.now();
                s.eVar82 = "invite | " + c_rulename;
                s.prop38 = c_deptname;
                s.prop17 = s.eVar45 = c_country;
                s.channel = s.eVar1 = s.prop5 = s.eVar6 = "Live-Chat";
                s.prop6 = s.eVar7 = c_shopname;
                s.events = "event50";
                s.tl();
            }
        }

        var loadJQuery = function () {

            if(typeof jQuery == "function") {
                jq = jQuery;
            } else {
                (function(e,undefined){var t,n,r=typeof undefined,i=e.location,o=e.document,s=o.documentElement,a=e.jQuery,u=e.$,c={},l=[],p="2.0.3 -sizzle,-deprecated",f=l.concat,h=l.push,d=l.slice,g=l.indexOf,m=c.toString,y=c.hasOwnProperty,v=p.trim,x=function(e,n){return new x.fn.init(e,n,t)},b=/[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,w=/\S+/g,T=/^(?:\s*(<[\w\W]+>)[^>]*|#([\w-]*))$/,k=/^<(\w+)\s*\/?>(?:<\/\1>|)$/,C=/^-ms-/,j=/-([\da-z])/gi,S=function(e,t){return t.toUpperCase()},N=function(){o.removeEventListener("DOMContentLoaded",N,!1),e.removeEventListener("load",N,!1),x.ready()};x.fn=x.prototype={jquery:p,constructor:x,init:function(e,t,n){var r,i;if(!e)return this;if("string"==typeof e){if(r="<"===e.charAt(0)&&">"===e.charAt(e.length-1)&&e.length>=3?[null,e,null]:T.exec(e),!r||!r[1]&&t)return!t||t.jquery?(t||n).find(e):this.constructor(t).find(e);if(r[1]){if(t=t instanceof x?t[0]:t,x.merge(this,x.parseHTML(r[1],t&&t.nodeType?t.ownerDocument||t:o,!0)),k.test(r[1])&&x.isPlainObject(t))for(r in t)x.isFunction(this[r])?this[r](t[r]):this.attr(r,t[r]);return this}return i=o.getElementById(r[2]),i&&i.parentNode&&(this.length=1,this[0]=i),this.context=o,this.selector=e,this}return e.nodeType?(this.context=this[0]=e,this.length=1,this):x.isFunction(e)?n.ready(e):(e.selector!==undefined&&(this.selector=e.selector,this.context=e.context),x.makeArray(e,this))},selector:"",length:0,toArray:function(){return d.call(this)},get:function(e){return null==e?this.toArray():0>e?this[this.length+e]:this[e]},pushStack:function(e){var t=x.merge(this.constructor(),e);return t.prevObject=this,t.context=this.context,t},each:function(e,t){return x.each(this,e,t)},ready:function(e){return x.ready.promise().done(e),this},slice:function(){return this.pushStack(d.apply(this,arguments))},first:function(){return this.eq(0)},last:function(){return this.eq(-1)},eq:function(e){var t=this.length,n=+e+(0>e?t:0);return this.pushStack(n>=0&&t>n?[this[n]]:[])},map:function(e){return this.pushStack(x.map(this,function(t,n){return e.call(t,n,t)}))},end:function(){return this.prevObject||this.constructor(null)},push:h,sort:[].sort,splice:[].splice},x.fn.init.prototype=x.fn,x.extend=x.fn.extend=function(){var e,t,n,r,i,o,s=arguments[0]||{},a=1,u=arguments.length,c=!1;for("boolean"==typeof s&&(c=s,s=arguments[1]||{},a=2),"object"==typeof s||x.isFunction(s)||(s={}),u===a&&(s=this,--a);u>a;a++)if(null!=(e=arguments[a]))for(t in e)n=s[t],r=e[t],s!==r&&(c&&r&&(x.isPlainObject(r)||(i=x.isArray(r)))?(i?(i=!1,o=n&&x.isArray(n)?n:[]):o=n&&x.isPlainObject(n)?n:{},s[t]=x.extend(c,o,r)):r!==undefined&&(s[t]=r));return s},x.extend({expando:"jQuery"+(p+Math.random()).replace(/\D/g,""),noConflict:function(t){return e.$===x&&(e.$=u),t&&e.jQuery===x&&(e.jQuery=a),x},isReady:!1,readyWait:1,holdReady:function(e){e?x.readyWait++:x.ready(!0)},ready:function(e){(e===!0?--x.readyWait:x.isReady)||(x.isReady=!0,e!==!0&&--x.readyWait>0||(n.resolveWith(o,[x]),x.fn.trigger&&x(o).trigger("ready").off("ready")))},isFunction:function(e){return"function"===x.type(e)},isArray:Array.isArray,isWindow:function(e){return null!=e&&e===e.window},isNumeric:function(e){return!isNaN(parseFloat(e))&&isFinite(e)},type:function(e){return null==e?e+"":"object"==typeof e||"function"==typeof e?c[m.call(e)]||"object":typeof e},isPlainObject:function(e){if("object"!==x.type(e)||e.nodeType||x.isWindow(e))return!1;try{if(e.constructor&&!y.call(e.constructor.prototype,"isPrototypeOf"))return!1}catch(t){return!1}return!0},isEmptyObject:function(e){var t;for(t in e)return!1;return!0},error:function(e){throw Error(e)},parseHTML:function(e,t,n){if(!e||"string"!=typeof e)return null;"boolean"==typeof t&&(n=t,t=!1),t=t||o;var r=k.exec(e),i=!n&&[];return r?[t.createElement(r[1])]:(r=x.buildFragment([e],t,i),i&&x(i).remove(),x.merge([],r.childNodes))},parseJSON:JSON.parse,parseXML:function(e){var t,n;if(!e||"string"!=typeof e)return null;try{n=new DOMParser,t=n.parseFromString(e,"text/xml")}catch(r){t=undefined}return(!t||t.getElementsByTagName("parsererror").length)&&x.error("Invalid XML: "+e),t},noop:function(){},globalEval:function(e){var t,n=eval;e=x.trim(e),e&&(1===e.indexOf("use strict")?(t=o.createElement("script"),t.text=e,o.head.appendChild(t).parentNode.removeChild(t)):n(e))},camelCase:function(e){return e.replace(C,"ms-").replace(j,S)},nodeName:function(e,t){return e.nodeName&&e.nodeName.toLowerCase()===t.toLowerCase()},each:function(e,t,n){var r,i=0,o=e.length,s=D(e);if(n){if(s){for(;o>i;i++)if(r=t.apply(e[i],n),r===!1)break}else for(i in e)if(r=t.apply(e[i],n),r===!1)break}else if(s){for(;o>i;i++)if(r=t.call(e[i],i,e[i]),r===!1)break}else for(i in e)if(r=t.call(e[i],i,e[i]),r===!1)break;return e},trim:function(e){return null==e?"":v.call(e)},makeArray:function(e,t){var n=t||[];return null!=e&&(D(Object(e))?x.merge(n,"string"==typeof e?[e]:e):h.call(n,e)),n},inArray:function(e,t,n){return null==t?-1:g.call(t,e,n)},merge:function(e,t){var n=t.length,r=e.length,i=0;if("number"==typeof n)for(;n>i;i++)e[r++]=t[i];else while(t[i]!==undefined)e[r++]=t[i++];return e.length=r,e},grep:function(e,t,n){var r,i=[],o=0,s=e.length;for(n=!!n;s>o;o++)r=!!t(e[o],o),n!==r&&i.push(e[o]);return i},map:function(e,t,n){var r,i=0,o=e.length,s=D(e),a=[];if(s)for(;o>i;i++)r=t(e[i],i,n),null!=r&&(a[a.length]=r);else for(i in e)r=t(e[i],i,n),null!=r&&(a[a.length]=r);return f.apply([],a)},guid:1,proxy:function(e,t){var n,r,i;return"string"==typeof t&&(n=e[t],t=e,e=n),x.isFunction(e)?(r=d.call(arguments,2),i=function(){return e.apply(t||this,r.concat(d.call(arguments)))},i.guid=e.guid=e.guid||x.guid++,i):undefined},access:function(e,t,n,r,i,o,s){var a=0,u=e.length,c=null==n;if("object"===x.type(n)){i=!0;for(a in n)x.access(e,t,a,n[a],!0,o,s)}else if(r!==undefined&&(i=!0,x.isFunction(r)||(s=!0),c&&(s?(t.call(e,r),t=null):(c=t,t=function(e,t,n){return c.call(x(e),n)})),t))for(;u>a;a++)t(e[a],n,s?r:r.call(e[a],a,t(e[a],n)));return i?e:c?t.call(e):u?t(e[0],n):o},now:Date.now,swap:function(e,t,n,r){var i,o,s={};for(o in t)s[o]=e.style[o],e.style[o]=t[o];i=n.apply(e,r||[]);for(o in t)e.style[o]=s[o];return i}}),x.ready.promise=function(t){return n||(n=x.Deferred(),"complete"===o.readyState?setTimeout(x.ready):(o.addEventListener("DOMContentLoaded",N,!1),e.addEventListener("load",N,!1))),n.promise(t)},x.each("Boolean Number String Function Array Date RegExp Object Error".split(" "),function(e,t){c["[object "+t+"]"]=t.toLowerCase()});function D(e){var t=e.length,n=x.type(e);return x.isWindow(e)?!1:1===e.nodeType&&t?!0:"array"===n||"function"!==n&&(0===t||"number"==typeof t&&t>0&&t-1 in e)}t=x(o);var E,H=s.webkitMatchesSelector||s.mozMatchesSelector||s.oMatchesSelector||s.msMatchesSelector,A=function(e,t){if(e===t)return E=!0,0;var n=t.compareDocumentPosition&&e.compareDocumentPosition&&e.compareDocumentPosition(t);return n?1&n?e===o||x.contains(o,e)?-1:t===o||x.contains(o,t)?1:0:4&n?-1:1:e.compareDocumentPosition?-1:1};x.extend({find:function(e,t,n,r){var i,s,a=0;if(n=n||[],t=t||o,!e||"string"!=typeof e)return n;if(1!==(s=t.nodeType)&&9!==s)return[];if(r)while(i=r[a++])x.find.matchesSelector(i,e)&&n.push(i);else x.merge(n,t.querySelectorAll(e));return n},unique:function(e){var t,n=[],r=0,i=0;if(E=!1,e.sort(A),E){while(t=e[r++])t===e[r]&&(i=n.push(r));while(i--)e.splice(n[i],1)}return e},text:function(e){var t,n="",r=0,i=e.nodeType;if(i){if(1===i||9===i||11===i)return e.textContent;if(3===i||4===i)return e.nodeValue}else while(t=e[r++])n+=x.text(t);return n},contains:function(e,t){var n=9===e.nodeType?e.documentElement:e,r=t&&t.parentNode;return e===r||!(!r||1!==r.nodeType||!n.contains(r))},isXMLDoc:function(e){return"HTML"!==(e.ownerDocument||e).documentElement.nodeName},expr:{attrHandle:{},match:{bool:/^(?:checked|selected|async|autofocus|autoplay|controls|defer|disabled|hidden|ismap|loop|multiple|open|readonly|required|scoped)$/i,needsContext:/^[\x20\t\r\n\f]*[>+~]/}}}),x.extend(x.find,{matches:function(e,t){return x.find(e,null,null,t)},matchesSelector:function(e,t){return H.call(e,t)},attr:function(e,t){return e.getAttribute(t)}});var q={};function O(e){var t=q[e]={};return x.each(e.match(w)||[],function(e,n){t[n]=!0}),t}x.Callbacks=function(e){e="string"==typeof e?q[e]||O(e):x.extend({},e);var t,n,r,i,o,s,a=[],u=!e.once&&[],c=function(p){for(t=e.memory&&p,n=!0,s=i||0,i=0,o=a.length,r=!0;a&&o>s;s++)if(a[s].apply(p[0],p[1])===!1&&e.stopOnFalse){t=!1;break}r=!1,a&&(u?u.length&&c(u.shift()):t?a=[]:l.disable())},l={add:function(){if(a){var n=a.length;(function s(t){x.each(t,function(t,n){var r=x.type(n);"function"===r?e.unique&&l.has(n)||a.push(n):n&&n.length&&"string"!==r&&s(n)})})(arguments),r?o=a.length:t&&(i=n,c(t))}return this},remove:function(){return a&&x.each(arguments,function(e,t){var n;while((n=x.inArray(t,a,n))>-1)a.splice(n,1),r&&(o>=n&&o--,s>=n&&s--)}),this},has:function(e){return e?x.inArray(e,a)>-1:!(!a||!a.length)},empty:function(){return a=[],o=0,this},disable:function(){return a=u=t=undefined,this},disabled:function(){return!a},lock:function(){return u=undefined,t||l.disable(),this},locked:function(){return!u},fireWith:function(e,t){return!a||n&&!u||(t=t||[],t=[e,t.slice?t.slice():t],r?u.push(t):c(t)),this},fire:function(){return l.fireWith(this,arguments),this},fired:function(){return!!n}};return l},x.extend({Deferred:function(e){var t=[["resolve","done",x.Callbacks("once memory"),"resolved"],["reject","fail",x.Callbacks("once memory"),"rejected"],["notify","progress",x.Callbacks("memory")]],n="pending",r={state:function(){return n},always:function(){return i.done(arguments).fail(arguments),this},then:function(){var e=arguments;return x.Deferred(function(n){x.each(t,function(t,o){var s=o[0],a=x.isFunction(e[t])&&e[t];i[o[1]](function(){var e=a&&a.apply(this,arguments);e&&x.isFunction(e.promise)?e.promise().done(n.resolve).fail(n.reject).progress(n.notify):n[s+"With"](this===r?n.promise():this,a?[e]:arguments)})}),e=null}).promise()},promise:function(e){return null!=e?x.extend(e,r):r}},i={};return r.pipe=r.then,x.each(t,function(e,o){var s=o[2],a=o[3];r[o[1]]=s.add,a&&s.add(function(){n=a},t[1^e][2].disable,t[2][2].lock),i[o[0]]=function(){return i[o[0]+"With"](this===i?r:this,arguments),this},i[o[0]+"With"]=s.fireWith}),r.promise(i),e&&e.call(i,i),i},when:function(e){var t=0,n=d.call(arguments),r=n.length,i=1!==r||e&&x.isFunction(e.promise)?r:0,o=1===i?e:x.Deferred(),s=function(e,t,n){return function(r){t[e]=this,n[e]=arguments.length>1?d.call(arguments):r,n===a?o.notifyWith(t,n):--i||o.resolveWith(t,n)}},a,u,c;if(r>1)for(a=Array(r),u=Array(r),c=Array(r);r>t;t++)n[t]&&x.isFunction(n[t].promise)?n[t].promise().done(s(t,c,n)).fail(o.reject).progress(s(t,u,a)):--i;return i||o.resolveWith(c,n),o.promise()}}),x.support=function(t){var n=o.createElement("input"),r=o.createDocumentFragment(),i=o.createElement("div"),s=o.createElement("select"),a=s.appendChild(o.createElement("option"));return n.type?(n.type="checkbox",t.checkOn=""!==n.value,t.optSelected=a.selected,t.reliableMarginRight=!0,t.boxSizingReliable=!0,t.pixelPosition=!1,n.checked=!0,t.noCloneChecked=n.cloneNode(!0).checked,s.disabled=!0,t.optDisabled=!a.disabled,n=o.createElement("input"),n.value="t",n.type="radio",t.radioValue="t"===n.value,n.setAttribute("checked","t"),n.setAttribute("name","t"),r.appendChild(n),t.checkClone=r.cloneNode(!0).cloneNode(!0).lastChild.checked,t.focusinBubbles="onfocusin"in e,i.style.backgroundClip="content-box",i.cloneNode(!0).style.backgroundClip="",t.clearCloneStyle="content-box"===i.style.backgroundClip,x(function(){var n,r,s="padding:0;margin:0;border:0;display:block;-webkit-box-sizing:content-box;-moz-box-sizing:content-box;box-sizing:content-box",a=o.getElementsByTagName("body")[0];a&&(n=o.createElement("div"),n.style.cssText="border:0;width:0;height:0;position:absolute;top:0;left:-9999px;margin-top:1px",a.appendChild(n).appendChild(i),i.innerHTML="",i.style.cssText="-webkit-box-sizing:border-box;-moz-box-sizing:border-box;box-sizing:border-box;padding:1px;border:1px;display:block;width:4px;margin-top:1%;position:absolute;top:1%",x.swap(a,null!=a.style.zoom?{zoom:1}:{},function(){t.boxSizing=4===i.offsetWidth}),e.getComputedStyle&&(t.pixelPosition="1%"!==(e.getComputedStyle(i,null)||{}).top,t.boxSizingReliable="4px"===(e.getComputedStyle(i,null)||{width:"4px"}).width,r=i.appendChild(o.createElement("div")),r.style.cssText=i.style.cssText=s,r.style.marginRight=r.style.width="0",i.style.width="1px",t.reliableMarginRight=!parseFloat((e.getComputedStyle(r,null)||{}).marginRight)),a.removeChild(n))}),t):t}({});var F,L,P=/(?:\{[\s\S]*\}|\[[\s\S]*\])$/,M=/([A-Z])/g;function W(){Object.defineProperty(this.cache={},0,{get:function(){return{}}}),this.expando=x.expando+Math.random()}W.uid=1,W.accepts=function(e){return e.nodeType?1===e.nodeType||9===e.nodeType:!0},W.prototype={key:function(e){if(!W.accepts(e))return 0;var t={},n=e[this.expando];if(!n){n=W.uid++;try{t[this.expando]={value:n},Object.defineProperties(e,t)}catch(r){t[this.expando]=n,x.extend(e,t)}}return this.cache[n]||(this.cache[n]={}),n},set:function(e,t,n){var r,i=this.key(e),o=this.cache[i];if("string"==typeof t)o[t]=n;else if(x.isEmptyObject(o))x.extend(this.cache[i],t);else for(r in t)o[r]=t[r];return o},get:function(e,t){var n=this.cache[this.key(e)];return t===undefined?n:n[t]},access:function(e,t,n){var r;return t===undefined||t&&"string"==typeof t&&n===undefined?(r=this.get(e,t),r!==undefined?r:this.get(e,x.camelCase(t))):(this.set(e,t,n),n!==undefined?n:t)},remove:function(e,t){var n,r,i,o=this.key(e),s=this.cache[o];if(t===undefined)this.cache[o]={};else{x.isArray(t)?r=t.concat(t.map(x.camelCase)):(i=x.camelCase(t),t in s?r=[t,i]:(r=i,r=r in s?[r]:r.match(w)||[])),n=r.length;while(n--)delete s[r[n]]}},hasData:function(e){return!x.isEmptyObject(this.cache[e[this.expando]]||{})},discard:function(e){e[this.expando]&&delete this.cache[e[this.expando]]}},F=new W,L=new W,x.extend({acceptData:W.accepts,hasData:function(e){return F.hasData(e)||L.hasData(e)},data:function(e,t,n){return F.access(e,t,n)},removeData:function(e,t){F.remove(e,t)},_data:function(e,t,n){return L.access(e,t,n)},_removeData:function(e,t){L.remove(e,t)}}),x.fn.extend({data:function(e,t){var n,r,i=this[0],o=0,s=null;if(e===undefined){if(this.length&&(s=F.get(i),1===i.nodeType&&!L.get(i,"hasDataAttrs"))){for(n=i.attributes;n.length>o;o++)r=n[o].name,0===r.indexOf("data-")&&(r=x.camelCase(r.slice(5)),R(i,r,s[r]));L.set(i,"hasDataAttrs",!0)}return s}return"object"==typeof e?this.each(function(){F.set(this,e)}):x.access(this,function(t){var n,r=x.camelCase(e);if(i&&t===undefined){if(n=F.get(i,e),n!==undefined)return n;if(n=F.get(i,r),n!==undefined)return n;if(n=R(i,r,undefined),n!==undefined)return n}else this.each(function(){var n=F.get(this,r);F.set(this,r,t),-1!==e.indexOf("-")&&n!==undefined&&F.set(this,e,t)})},null,t,arguments.length>1,null,!0)},removeData:function(e){return this.each(function(){F.remove(this,e)})}});function R(e,t,n){var r;if(n===undefined&&1===e.nodeType)if(r="data-"+t.replace(M,"-$1").toLowerCase(),n=e.getAttribute(r),"string"==typeof n){try{n="true"===n?!0:"false"===n?!1:"null"===n?null:+n+""===n?+n:P.test(n)?JSON.parse(n):n}catch(i){}F.set(e,t,n)}else n=undefined;return n}x.extend({queue:function(e,t,n){var r;return e?(t=(t||"fx")+"queue",r=L.get(e,t),n&&(!r||x.isArray(n)?r=L.access(e,t,x.makeArray(n)):r.push(n)),r||[]):undefined},dequeue:function(e,t){t=t||"fx";var n=x.queue(e,t),r=n.length,i=n.shift(),o=x._queueHooks(e,t),s=function(){x.dequeue(e,t)};"inprogress"===i&&(i=n.shift(),r--),i&&("fx"===t&&n.unshift("inprogress"),delete o.stop,i.call(e,s,o)),!r&&o&&o.empty.fire()},_queueHooks:function(e,t){var n=t+"queueHooks";return L.get(e,n)||L.access(e,n,{empty:x.Callbacks("once memory").add(function(){L.remove(e,[t+"queue",n])})})}}),x.fn.extend({queue:function(e,t){var n=2;return"string"!=typeof e&&(t=e,e="fx",n--),n>arguments.length?x.queue(this[0],e):t===undefined?this:this.each(function(){var n=x.queue(this,e,t);x._queueHooks(this,e),"fx"===e&&"inprogress"!==n[0]&&x.dequeue(this,e)})},dequeue:function(e){return this.each(function(){x.dequeue(this,e)})},delay:function(e,t){return e=x.fx?x.fx.speeds[e]||e:e,t=t||"fx",this.queue(t,function(t,n){var r=setTimeout(t,e);n.stop=function(){clearTimeout(r)}})},clearQueue:function(e){return this.queue(e||"fx",[])},promise:function(e,t){var n,r=1,i=x.Deferred(),o=this,s=this.length,a=function(){--r||i.resolveWith(o,[o])};"string"!=typeof e&&(t=e,e=undefined),e=e||"fx";while(s--)n=L.get(o[s],e+"queueHooks"),n&&n.empty&&(r++,n.empty.add(a));return a(),i.promise(t)}});var $,_,z=/[\t\r\n\f]/g,X=/\r/g,B=/^(?:input|select|textarea|button)$/i;x.fn.extend({attr:function(e,t){return x.access(this,x.attr,e,t,arguments.length>1)},removeAttr:function(e){return this.each(function(){x.removeAttr(this,e)})},prop:function(e,t){return x.access(this,x.prop,e,t,arguments.length>1)},removeProp:function(e){return this.each(function(){delete this[x.propFix[e]||e]})},addClass:function(e){var t,n,r,i,o,s=0,a=this.length,u="string"==typeof e&&e;if(x.isFunction(e))return this.each(function(t){x(this).addClass(e.call(this,t,this.className))});if(u)for(t=(e||"").match(w)||[];a>s;s++)if(n=this[s],r=1===n.nodeType&&(n.className?(" "+n.className+" ").replace(z," "):" ")){o=0;while(i=t[o++])0>r.indexOf(" "+i+" ")&&(r+=i+" ");n.className=x.trim(r)}return this},removeClass:function(e){var t,n,r,i,o,s=0,a=this.length,u=0===arguments.length||"string"==typeof e&&e;if(x.isFunction(e))return this.each(function(t){x(this).removeClass(e.call(this,t,this.className))});if(u)for(t=(e||"").match(w)||[];a>s;s++)if(n=this[s],r=1===n.nodeType&&(n.className?(" "+n.className+" ").replace(z," "):"")){o=0;while(i=t[o++])while(r.indexOf(" "+i+" ")>=0)r=r.replace(" "+i+" "," ");n.className=e?x.trim(r):""}return this},toggleClass:function(e,t){var n=typeof e;return"boolean"==typeof t&&"string"===n?t?this.addClass(e):this.removeClass(e):x.isFunction(e)?this.each(function(n){x(this).toggleClass(e.call(this,n,this.className,t),t)}):this.each(function(){if("string"===n){var t,i=0,o=x(this),s=e.match(w)||[];while(t=s[i++])o.hasClass(t)?o.removeClass(t):o.addClass(t)}else(n===r||"boolean"===n)&&(this.className&&L.set(this,"__className__",this.className),this.className=this.className||e===!1?"":L.get(this,"__className__")||"")})},hasClass:function(e){var t=" "+e+" ",n=0,r=this.length;for(;r>n;n++)if(1===this[n].nodeType&&(" "+this[n].className+" ").replace(z," ").indexOf(t)>=0)return!0;return!1},val:function(e){var t,n,r,i=this[0];{if(arguments.length)return r=x.isFunction(e),this.each(function(n){var i;1===this.nodeType&&(i=r?e.call(this,n,x(this).val()):e,null==i?i="":"number"==typeof i?i+="":x.isArray(i)&&(i=x.map(i,function(e){return null==e?"":e+""})),t=x.valHooks[this.type]||x.valHooks[this.nodeName.toLowerCase()],t&&"set"in t&&t.set(this,i,"value")!==undefined||(this.value=i))});if(i)return t=x.valHooks[i.type]||x.valHooks[i.nodeName.toLowerCase()],t&&"get"in t&&(n=t.get(i,"value"))!==undefined?n:(n=i.value,"string"==typeof n?n.replace(X,""):null==n?"":n)}}}),x.extend({valHooks:{option:{get:function(e){var t=e.attributes.value;return!t||t.specified?e.value:e.text}},select:{get:function(e){var t,n,r=e.options,i=e.selectedIndex,o="select-one"===e.type||0>i,s=o?null:[],a=o?i+1:r.length,u=0>i?a:o?i:0;for(;a>u;u++)if(n=r[u],!(!n.selected&&u!==i||(x.support.optDisabled?n.disabled:null!==n.getAttribute("disabled"))||n.parentNode.disabled&&x.nodeName(n.parentNode,"optgroup"))){if(t=x(n).val(),o)return t;s.push(t)}return s},set:function(e,t){var n,r,i=e.options,o=x.makeArray(t),s=i.length;while(s--)r=i[s],(r.selected=x.inArray(x(r).val(),o)>=0)&&(n=!0);return n||(e.selectedIndex=-1),o}}},attr:function(e,t,n){var i,o,s=e.nodeType;if(e&&3!==s&&8!==s&&2!==s)return typeof e.getAttribute===r?x.prop(e,t,n):(1===s&&x.isXMLDoc(e)||(t=t.toLowerCase(),i=x.attrHooks[t]||(x.expr.match.bool.test(t)?_:$)),n===undefined?i&&"get"in i&&null!==(o=i.get(e,t))?o:(o=x.find.attr(e,t),null==o?undefined:o):null!==n?i&&"set"in i&&(o=i.set(e,n,t))!==undefined?o:(e.setAttribute(t,n+""),n):(x.removeAttr(e,t),undefined))},removeAttr:function(e,t){var n,r,i=0,o=t&&t.match(w);if(o&&1===e.nodeType)while(n=o[i++])r=x.propFix[n]||n,x.expr.match.bool.test(n)&&(e[r]=!1),e.removeAttribute(n)},attrHooks:{type:{set:function(e,t){if(!x.support.radioValue&&"radio"===t&&x.nodeName(e,"input")){var n=e.value;return e.setAttribute("type",t),n&&(e.value=n),t}}}},propFix:{"for":"htmlFor","class":"className"},prop:function(e,t,n){var r,i,o,s=e.nodeType;if(e&&3!==s&&8!==s&&2!==s)return o=1!==s||!x.isXMLDoc(e),o&&(t=x.propFix[t]||t,i=x.propHooks[t]),n!==undefined?i&&"set"in i&&(r=i.set(e,n,t))!==undefined?r:e[t]=n:i&&"get"in i&&null!==(r=i.get(e,t))?r:e[t]},propHooks:{tabIndex:{get:function(e){return e.hasAttribute("tabindex")||B.test(e.nodeName)||e.href?e.tabIndex:-1}}}}),_={set:function(e,t,n){return t===!1?x.removeAttr(e,n):e.setAttribute(n,n),n}},x.each(x.expr.match.bool.source.match(/\w+/g),function(e,t){var n=x.expr.attrHandle[t]||x.find.attr;x.expr.attrHandle[t]=function(e,t,r){var i=x.expr.attrHandle[t],o=r?undefined:(x.expr.attrHandle[t]=undefined)!=n(e,t,r)?t.toLowerCase():null;return x.expr.attrHandle[t]=i,o}}),x.support.optSelected||(x.propHooks.selected={get:function(e){var t=e.parentNode;return t&&t.parentNode&&t.parentNode.selectedIndex,null}}),x.each(["tabIndex","readOnly","maxLength","cellSpacing","cellPadding","rowSpan","colSpan","useMap","frameBorder","contentEditable"],function(){x.propFix[this.toLowerCase()]=this}),x.each(["radio","checkbox"],function(){x.valHooks[this]={set:function(e,t){return x.isArray(t)?e.checked=x.inArray(x(e).val(),t)>=0:undefined}},x.support.checkOn||(x.valHooks[this].get=function(e){return null===e.getAttribute("value")?"on":e.value})});var I=/^key/,U=/^(?:mouse|contextmenu)|click/,Y=/^(?:focusinfocus|focusoutblur)$/,V=/^([^.]*)(?:\.(.+)|)$/;function J(){return!0}function Q(){return!1}function G(){try{return o.activeElement}catch(e){}}x.event={global:{},add:function(e,t,n,i,o){var s,a,u,c,l,p,f,h,d,g,m,y=L.get(e);if(y){n.handler&&(s=n,n=s.handler,o=s.selector),n.guid||(n.guid=x.guid++),(c=y.events)||(c=y.events={}),(a=y.handle)||(a=y.handle=function(e){return typeof x===r||e&&x.event.triggered===e.type?undefined:x.event.dispatch.apply(a.elem,arguments)},a.elem=e),t=(t||"").match(w)||[""],l=t.length;while(l--)u=V.exec(t[l])||[],d=m=u[1],g=(u[2]||"").split(".").sort(),d&&(f=x.event.special[d]||{},d=(o?f.delegateType:f.bindType)||d,f=x.event.special[d]||{},p=x.extend({type:d,origType:m,data:i,handler:n,guid:n.guid,selector:o,needsContext:o&&x.expr.match.needsContext.test(o),namespace:g.join(".")},s),(h=c[d])||(h=c[d]=[],h.delegateCount=0,f.setup&&f.setup.call(e,i,g,a)!==!1||e.addEventListener&&e.addEventListener(d,a,!1)),f.add&&(f.add.call(e,p),p.handler.guid||(p.handler.guid=n.guid)),o?h.splice(h.delegateCount++,0,p):h.push(p),x.event.global[d]=!0);e=null}},remove:function(e,t,n,r,i){var o,s,a,u,c,l,p,f,h,d,g,m=L.hasData(e)&&L.get(e);if(m&&(u=m.events)){t=(t||"").match(w)||[""],c=t.length;while(c--)if(a=V.exec(t[c])||[],h=g=a[1],d=(a[2]||"").split(".").sort(),h){p=x.event.special[h]||{},h=(r?p.delegateType:p.bindType)||h,f=u[h]||[],a=a[2]&&RegExp("(^|\\.)"+d.join("\\.(?:.*\\.|)")+"(\\.|$)"),s=o=f.length;while(o--)l=f[o],!i&&g!==l.origType||n&&n.guid!==l.guid||a&&!a.test(l.namespace)||r&&r!==l.selector&&("**"!==r||!l.selector)||(f.splice(o,1),l.selector&&f.delegateCount--,p.remove&&p.remove.call(e,l));s&&!f.length&&(p.teardown&&p.teardown.call(e,d,m.handle)!==!1||x.removeEvent(e,h,m.handle),delete u[h])}else for(h in u)x.event.remove(e,h+t[c],n,r,!0);x.isEmptyObject(u)&&(delete m.handle,L.remove(e,"events"))}},trigger:function(t,n,r,i){var s,a,u,c,l,p,f,h=[r||o],d=y.call(t,"type")?t.type:t,g=y.call(t,"namespace")?t.namespace.split("."):[];if(a=u=r=r||o,3!==r.nodeType&&8!==r.nodeType&&!Y.test(d+x.event.triggered)&&(d.indexOf(".")>=0&&(g=d.split("."),d=g.shift(),g.sort()),l=0>d.indexOf(":")&&"on"+d,t=t[x.expando]?t:new x.Event(d,"object"==typeof t&&t),t.isTrigger=i?2:3,t.namespace=g.join("."),t.namespace_re=t.namespace?RegExp("(^|\\.)"+g.join("\\.(?:.*\\.|)")+"(\\.|$)"):null,t.result=undefined,t.target||(t.target=r),n=null==n?[t]:x.makeArray(n,[t]),f=x.event.special[d]||{},i||!f.trigger||f.trigger.apply(r,n)!==!1)){if(!i&&!f.noBubble&&!x.isWindow(r)){for(c=f.delegateType||d,Y.test(c+d)||(a=a.parentNode);a;a=a.parentNode)h.push(a),u=a;u===(r.ownerDocument||o)&&h.push(u.defaultView||u.parentWindow||e)}s=0;while((a=h[s++])&&!t.isPropagationStopped())t.type=s>1?c:f.bindType||d,p=(L.get(a,"events")||{})[t.type]&&L.get(a,"handle"),p&&p.apply(a,n),p=l&&a[l],p&&x.acceptData(a)&&p.apply&&p.apply(a,n)===!1&&t.preventDefault();return t.type=d,i||t.isDefaultPrevented()||f._default&&f._default.apply(h.pop(),n)!==!1||!x.acceptData(r)||l&&x.isFunction(r[d])&&!x.isWindow(r)&&(u=r[l],u&&(r[l]=null),x.event.triggered=d,r[d](),x.event.triggered=undefined,u&&(r[l]=u)),t.result}},dispatch:function(e){e=x.event.fix(e);var t,n,r,i,o,s=[],a=d.call(arguments),u=(L.get(this,"events")||{})[e.type]||[],c=x.event.special[e.type]||{};if(a[0]=e,e.delegateTarget=this,!c.preDispatch||c.preDispatch.call(this,e)!==!1){s=x.event.handlers.call(this,e,u),t=0;while((i=s[t++])&&!e.isPropagationStopped()){e.currentTarget=i.elem,n=0;while((o=i.handlers[n++])&&!e.isImmediatePropagationStopped())(!e.namespace_re||e.namespace_re.test(o.namespace))&&(e.handleObj=o,e.data=o.data,r=((x.event.special[o.origType]||{}).handle||o.handler).apply(i.elem,a),r!==undefined&&(e.result=r)===!1&&(e.preventDefault(),e.stopPropagation()))}return c.postDispatch&&c.postDispatch.call(this,e),e.result}},handlers:function(e,t){var n,r,i,o,s=[],a=t.delegateCount,u=e.target;if(a&&u.nodeType&&(!e.button||"click"!==e.type))for(;u!==this;u=u.parentNode||this)if(u.disabled!==!0||"click"!==e.type){for(r=[],n=0;a>n;n++)o=t[n],i=o.selector+" ",r[i]===undefined&&(r[i]=o.needsContext?x(i,this).index(u)>=0:x.find(i,this,null,[u]).length),r[i]&&r.push(o);r.length&&s.push({elem:u,handlers:r})}return t.length>a&&s.push({elem:this,handlers:t.slice(a)}),s},props:"altKey bubbles cancelable ctrlKey currentTarget eventPhase metaKey relatedTarget shiftKey target timeStamp view which".split(" "),fixHooks:{},keyHooks:{props:"char charCode key keyCode".split(" "),filter:function(e,t){return null==e.which&&(e.which=null!=t.charCode?t.charCode:t.keyCode),e}},mouseHooks:{props:"button buttons clientX clientY offsetX offsetY pageX pageY screenX screenY toElement".split(" "),filter:function(e,t){var n,r,i,s=t.button;return null==e.pageX&&null!=t.clientX&&(n=e.target.ownerDocument||o,r=n.documentElement,i=n.body,e.pageX=t.clientX+(r&&r.scrollLeft||i&&i.scrollLeft||0)-(r&&r.clientLeft||i&&i.clientLeft||0),e.pageY=t.clientY+(r&&r.scrollTop||i&&i.scrollTop||0)-(r&&r.clientTop||i&&i.clientTop||0)),e.which||s===undefined||(e.which=1&s?1:2&s?3:4&s?2:0),e}},fix:function(e){if(e[x.expando])return e;var t,n,r,i=e.type,s=e,a=this.fixHooks[i];a||(this.fixHooks[i]=a=U.test(i)?this.mouseHooks:I.test(i)?this.keyHooks:{}),r=a.props?this.props.concat(a.props):this.props,e=new x.Event(s),t=r.length;while(t--)n=r[t],e[n]=s[n];return e.target||(e.target=o),3===e.target.nodeType&&(e.target=e.target.parentNode),a.filter?a.filter(e,s):e},special:{load:{noBubble:!0},focus:{trigger:function(){return this!==G()&&this.focus?(this.focus(),!1):undefined},delegateType:"focusin"},blur:{trigger:function(){return this===G()&&this.blur?(this.blur(),!1):undefined},delegateType:"focusout"},click:{trigger:function(){return"checkbox"===this.type&&this.click&&x.nodeName(this,"input")?(this.click(),!1):undefined},_default:function(e){return x.nodeName(e.target,"a")}},beforeunload:{postDispatch:function(e){e.result!==undefined&&(e.originalEvent.returnValue=e.result)}}},simulate:function(e,t,n,r){var i=x.extend(new x.Event,n,{type:e,isSimulated:!0,originalEvent:{}});r?x.event.trigger(i,null,t):x.event.dispatch.call(t,i),i.isDefaultPrevented()&&n.preventDefault()}},x.removeEvent=function(e,t,n){e.removeEventListener&&e.removeEventListener(t,n,!1)},x.Event=function(e,t){return this instanceof x.Event?(e&&e.type?(this.originalEvent=e,this.type=e.type,this.isDefaultPrevented=e.defaultPrevented||e.getPreventDefault&&e.getPreventDefault()?J:Q):this.type=e,t&&x.extend(this,t),this.timeStamp=e&&e.timeStamp||x.now(),this[x.expando]=!0,undefined):new x.Event(e,t)},x.Event.prototype={isDefaultPrevented:Q,isPropagationStopped:Q,isImmediatePropagationStopped:Q,preventDefault:function(){var e=this.originalEvent;this.isDefaultPrevented=J,e&&e.preventDefault&&e.preventDefault()},stopPropagation:function(){var e=this.originalEvent;this.isPropagationStopped=J,e&&e.stopPropagation&&e.stopPropagation()},stopImmediatePropagation:function(){this.isImmediatePropagationStopped=J,this.stopPropagation()}},x.each({mouseenter:"mouseover",mouseleave:"mouseout"},function(e,t){x.event.special[e]={delegateType:t,bindType:t,handle:function(e){var n,r=this,i=e.relatedTarget,o=e.handleObj;return(!i||i!==r&&!x.contains(r,i))&&(e.type=o.origType,n=o.handler.apply(this,arguments),e.type=t),n}}}),x.support.focusinBubbles||x.each({focus:"focusin",blur:"focusout"},function(e,t){var n=0,r=function(e){x.event.simulate(t,e.target,x.event.fix(e),!0)};x.event.special[t]={setup:function(){0===n++&&o.addEventListener(e,r,!0)},teardown:function(){0===--n&&o.removeEventListener(e,r,!0)}}}),x.fn.extend({on:function(e,t,n,r,i){var o,s;if("object"==typeof e){"string"!=typeof t&&(n=n||t,t=undefined);for(s in e)this.on(s,t,n,e[s],i);return this}if(null==n&&null==r?(r=t,n=t=undefined):null==r&&("string"==typeof t?(r=n,n=undefined):(r=n,n=t,t=undefined)),r===!1)r=Q;else if(!r)return this;return 1===i&&(o=r,r=function(e){return x().off(e),o.apply(this,arguments)},r.guid=o.guid||(o.guid=x.guid++)),this.each(function(){x.event.add(this,e,r,n,t)})},one:function(e,t,n,r){return this.on(e,t,n,r,1)},off:function(e,t,n){var r,i;if(e&&e.preventDefault&&e.handleObj)return r=e.handleObj,x(e.delegateTarget).off(r.namespace?r.origType+"."+r.namespace:r.origType,r.selector,r.handler),this;if("object"==typeof e){for(i in e)this.off(i,t,e[i]);return this}return(t===!1||"function"==typeof t)&&(n=t,t=undefined),n===!1&&(n=Q),this.each(function(){x.event.remove(this,e,n,t)})},trigger:function(e,t){return this.each(function(){x.event.trigger(e,t,this)})},triggerHandler:function(e,t){var n=this[0];return n?x.event.trigger(e,t,n,!0):undefined}});var K=/^.[^:#\[\.,]*$/,Z=/^(?:parents|prev(?:Until|All))/,et=x.expr.match.needsContext,tt={children:!0,contents:!0,next:!0,prev:!0};x.fn.extend({find:function(e){var t,n=[],r=this,i=r.length;if("string"!=typeof e)return this.pushStack(x(e).filter(function(){for(t=0;i>t;t++)if(x.contains(r[t],this))return!0}));for(t=0;i>t;t++)x.find(e,r[t],n);return n=this.pushStack(i>1?x.unique(n):n),n.selector=this.selector?this.selector+" "+e:e,n},has:function(e){var t=x(e,this),n=t.length;return this.filter(function(){var e=0;for(;n>e;e++)if(x.contains(this,t[e]))return!0})},not:function(e){return this.pushStack(rt(this,e||[],!0))},filter:function(e){return this.pushStack(rt(this,e||[],!1))},is:function(e){return!!rt(this,"string"==typeof e&&et.test(e)?x(e):e||[],!1).length},closest:function(e,t){var n,r=0,i=this.length,o=[],s=et.test(e)||"string"!=typeof e?x(e,t||this.context):0;for(;i>r;r++)for(n=this[r];n&&n!==t;n=n.parentNode)if(11>n.nodeType&&(s?s.index(n)>-1:1===n.nodeType&&x.find.matchesSelector(n,e))){n=o.push(n);break}return this.pushStack(o.length>1?x.unique(o):o)},index:function(e){return e?"string"==typeof e?g.call(x(e),this[0]):g.call(this,e.jquery?e[0]:e):this[0]&&this[0].parentNode?this.first().prevAll().length:-1},add:function(e,t){var n="string"==typeof e?x(e,t):x.makeArray(e&&e.nodeType?[e]:e),r=x.merge(this.get(),n);return this.pushStack(x.unique(r))},addBack:function(e){return this.add(null==e?this.prevObject:this.prevObject.filter(e))}});function nt(e,t){while((e=e[t])&&1!==e.nodeType);return e}x.each({parent:function(e){var t=e.parentNode;return t&&11!==t.nodeType?t:null
                    },parents:function(e){return x.dir(e,"parentNode")},parentsUntil:function(e,t,n){return x.dir(e,"parentNode",n)},next:function(e){return nt(e,"nextSibling")},prev:function(e){return nt(e,"previousSibling")},nextAll:function(e){return x.dir(e,"nextSibling")},prevAll:function(e){return x.dir(e,"previousSibling")},nextUntil:function(e,t,n){return x.dir(e,"nextSibling",n)},prevUntil:function(e,t,n){return x.dir(e,"previousSibling",n)},siblings:function(e){return x.sibling((e.parentNode||{}).firstChild,e)},children:function(e){return x.sibling(e.firstChild)},contents:function(e){return e.contentDocument||x.merge([],e.childNodes)}},function(e,t){x.fn[e]=function(n,r){var i=x.map(this,t,n);return"Until"!==e.slice(-5)&&(r=n),r&&"string"==typeof r&&(i=x.filter(r,i)),this.length>1&&(tt[e]||x.unique(i),Z.test(e)&&i.reverse()),this.pushStack(i)}}),x.extend({filter:function(e,t,n){var r=t[0];return n&&(e=":not("+e+")"),1===t.length&&1===r.nodeType?x.find.matchesSelector(r,e)?[r]:[]:x.find.matches(e,x.grep(t,function(e){return 1===e.nodeType}))},dir:function(e,t,n){var r=[],i=n!==undefined;while((e=e[t])&&9!==e.nodeType)if(1===e.nodeType){if(i&&x(e).is(n))break;r.push(e)}return r},sibling:function(e,t){var n=[];for(;e;e=e.nextSibling)1===e.nodeType&&e!==t&&n.push(e);return n}});function rt(e,t,n){if(x.isFunction(t))return x.grep(e,function(e,r){return!!t.call(e,r,e)!==n});if(t.nodeType)return x.grep(e,function(e){return e===t!==n});if("string"==typeof t){if(K.test(t))return x.filter(t,e,n);t=x.filter(t,e)}return x.grep(e,function(e){return g.call(t,e)>=0!==n})}var it=/<(?!area|br|col|embed|hr|img|input|link|meta|param)(([\w:]+)[^>]*)\/>/gi,ot=/<([\w:]+)/,st=/<|&#?\w+;/,at=/<(?:script|style|link)/i,ut=/^(?:checkbox|radio)$/i,ct=/checked\s*(?:[^=]|=\s*.checked.)/i,lt=/^$|\/(?:java|ecma)script/i,pt=/^true\/(.*)/,ft=/^\s*<!(?:\[CDATA\[|--)|(?:\]\]|--)>\s*$/g,ht={option:[1,"<select multiple='multiple'>","</select>"],thead:[1,"<table>","</table>"],col:[2,"<table><colgroup>","</colgroup></table>"],tr:[2,"<table><tbody>","</tbody></table>"],td:[3,"<table><tbody><tr>","</tr></tbody></table>"],_default:[0,"",""]};ht.optgroup=ht.option,ht.tbody=ht.tfoot=ht.colgroup=ht.caption=ht.thead,ht.th=ht.td,x.fn.extend({text:function(e){return x.access(this,function(e){return e===undefined?x.text(this):this.empty().append((this[0]&&this[0].ownerDocument||o).createTextNode(e))},null,e,arguments.length)},append:function(){return this.domManip(arguments,function(e){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var t=dt(this,e);t.appendChild(e)}})},prepend:function(){return this.domManip(arguments,function(e){if(1===this.nodeType||11===this.nodeType||9===this.nodeType){var t=dt(this,e);t.insertBefore(e,t.firstChild)}})},before:function(){return this.domManip(arguments,function(e){this.parentNode&&this.parentNode.insertBefore(e,this)})},after:function(){return this.domManip(arguments,function(e){this.parentNode&&this.parentNode.insertBefore(e,this.nextSibling)})},remove:function(e,t){var n,r=e?x.filter(e,this):this,i=0;for(;null!=(n=r[i]);i++)t||1!==n.nodeType||x.cleanData(xt(n)),n.parentNode&&(t&&x.contains(n.ownerDocument,n)&&yt(xt(n,"script")),n.parentNode.removeChild(n));return this},empty:function(){var e,t=0;for(;null!=(e=this[t]);t++)1===e.nodeType&&(x.cleanData(xt(e,!1)),e.textContent="");return this},clone:function(e,t){return e=null==e?!1:e,t=null==t?e:t,this.map(function(){return x.clone(this,e,t)})},html:function(e){return x.access(this,function(e){var t=this[0]||{},n=0,r=this.length;if(e===undefined&&1===t.nodeType)return t.innerHTML;if("string"==typeof e&&!at.test(e)&&!ht[(ot.exec(e)||["",""])[1].toLowerCase()]){e=e.replace(it,"<$1></$2>");try{for(;r>n;n++)t=this[n]||{},1===t.nodeType&&(x.cleanData(xt(t,!1)),t.innerHTML=e);t=0}catch(i){}}t&&this.empty().append(e)},null,e,arguments.length)},replaceWith:function(){var e=x.map(this,function(e){return[e.nextSibling,e.parentNode]}),t=0;return this.domManip(arguments,function(n){var r=e[t++],i=e[t++];i&&(r&&r.parentNode!==i&&(r=this.nextSibling),x(this).remove(),i.insertBefore(n,r))},!0),t?this:this.remove()},detach:function(e){return this.remove(e,!0)},domManip:function(e,t,n){e=f.apply([],e);var r,i,o,s,a,u,c=0,l=this.length,p=this,h=l-1,d=e[0],g=x.isFunction(d);if(g||!(1>=l||"string"!=typeof d||x.support.checkClone)&&ct.test(d))return this.each(function(r){var i=p.eq(r);g&&(e[0]=d.call(this,r,i.html())),i.domManip(e,t,n)});if(l&&(r=x.buildFragment(e,this[0].ownerDocument,!1,!n&&this),i=r.firstChild,1===r.childNodes.length&&(r=i),i)){for(o=x.map(xt(r,"script"),gt),s=o.length;l>c;c++)a=r,c!==h&&(a=x.clone(a,!0,!0),s&&x.merge(o,xt(a,"script"))),t.call(this[c],a,c);if(s)for(u=o[o.length-1].ownerDocument,x.map(o,mt),c=0;s>c;c++)a=o[c],lt.test(a.type||"")&&!L.access(a,"globalEval")&&x.contains(u,a)&&(a.src?x._evalUrl(a.src):x.globalEval(a.textContent.replace(ft,"")))}return this}}),x.each({appendTo:"append",prependTo:"prepend",insertBefore:"before",insertAfter:"after",replaceAll:"replaceWith"},function(e,t){x.fn[e]=function(e){var n,r=[],i=x(e),o=i.length-1,s=0;for(;o>=s;s++)n=s===o?this:this.clone(!0),x(i[s])[t](n),h.apply(r,n.get());return this.pushStack(r)}}),x.extend({clone:function(e,t,n){var r,i,o,s,a=e.cloneNode(!0),u=x.contains(e.ownerDocument,e);if(!(x.support.noCloneChecked||1!==e.nodeType&&11!==e.nodeType||x.isXMLDoc(e)))for(s=xt(a),o=xt(e),r=0,i=o.length;i>r;r++)bt(o[r],s[r]);if(t)if(n)for(o=o||xt(e),s=s||xt(a),r=0,i=o.length;i>r;r++)vt(o[r],s[r]);else vt(e,a);return s=xt(a,"script"),s.length>0&&yt(s,!u&&xt(e,"script")),a},buildFragment:function(e,t,n,r){var i,o,s,a,u,c,l=0,p=e.length,f=t.createDocumentFragment(),h=[];for(;p>l;l++)if(i=e[l],i||0===i)if("object"===x.type(i))x.merge(h,i.nodeType?[i]:i);else if(st.test(i)){o=o||f.appendChild(t.createElement("div")),s=(ot.exec(i)||["",""])[1].toLowerCase(),a=ht[s]||ht._default,o.innerHTML=a[1]+i.replace(it,"<$1></$2>")+a[2],c=a[0];while(c--)o=o.lastChild;x.merge(h,o.childNodes),o=f.firstChild,o.textContent=""}else h.push(t.createTextNode(i));f.textContent="",l=0;while(i=h[l++])if((!r||-1===x.inArray(i,r))&&(u=x.contains(i.ownerDocument,i),o=xt(f.appendChild(i),"script"),u&&yt(o),n)){c=0;while(i=o[c++])lt.test(i.type||"")&&n.push(i)}return f},cleanData:function(e){var t,n,r,i,o,s,a=x.event.special,u=0;for(;(n=e[u])!==undefined;u++){if(W.accepts(n)&&(o=n[L.expando],o&&(t=L.cache[o]))){if(r=Object.keys(t.events||{}),r.length)for(s=0;(i=r[s])!==undefined;s++)a[i]?x.event.remove(n,i):x.removeEvent(n,i,t.handle);L.cache[o]&&delete L.cache[o]}delete F.cache[n[F.expando]]}},_evalUrl:function(e){return x.ajax({url:e,type:"GET",dataType:"script",async:!1,global:!1,"throws":!0})}});function dt(e,t){return x.nodeName(e,"table")&&x.nodeName(1===t.nodeType?t:t.firstChild,"tr")?e.getElementsByTagName("tbody")[0]||e.appendChild(e.ownerDocument.createElement("tbody")):e}function gt(e){return e.type=(null!==e.getAttribute("type"))+"/"+e.type,e}function mt(e){var t=pt.exec(e.type);return t?e.type=t[1]:e.removeAttribute("type"),e}function yt(e,t){var n=e.length,r=0;for(;n>r;r++)L.set(e[r],"globalEval",!t||L.get(t[r],"globalEval"))}function vt(e,t){var n,r,i,o,s,a,u,c;if(1===t.nodeType){if(L.hasData(e)&&(o=L.access(e),s=L.set(t,o),c=o.events)){delete s.handle,s.events={};for(i in c)for(n=0,r=c[i].length;r>n;n++)x.event.add(t,i,c[i][n])}F.hasData(e)&&(a=F.access(e),u=x.extend({},a),F.set(t,u))}}function xt(e,t){var n=e.getElementsByTagName?e.getElementsByTagName(t||"*"):e.querySelectorAll?e.querySelectorAll(t||"*"):[];return t===undefined||t&&x.nodeName(e,t)?x.merge([e],n):n}function bt(e,t){var n=t.nodeName.toLowerCase();"input"===n&&ut.test(e.type)?t.checked=e.checked:("input"===n||"textarea"===n)&&(t.defaultValue=e.defaultValue)}x.fn.extend({wrapAll:function(e){var t;return x.isFunction(e)?this.each(function(t){x(this).wrapAll(e.call(this,t))}):(this[0]&&(t=x(e,this[0].ownerDocument).eq(0).clone(!0),this[0].parentNode&&t.insertBefore(this[0]),t.map(function(){var e=this;while(e.firstElementChild)e=e.firstElementChild;return e}).append(this)),this)},wrapInner:function(e){return x.isFunction(e)?this.each(function(t){x(this).wrapInner(e.call(this,t))}):this.each(function(){var t=x(this),n=t.contents();n.length?n.wrapAll(e):t.append(e)})},wrap:function(e){var t=x.isFunction(e);return this.each(function(n){x(this).wrapAll(t?e.call(this,n):e)})},unwrap:function(){return this.parent().each(function(){x.nodeName(this,"body")||x(this).replaceWith(this.childNodes)}).end()}});var wt,Tt,kt=/^(none|table(?!-c[ea]).+)/,Ct=/^margin/,jt=RegExp("^("+b+")(.*)$","i"),St=RegExp("^("+b+")(?!px)[a-z%]+$","i"),Nt=RegExp("^([+-])=("+b+")","i"),Dt={BODY:"block"},Et={position:"absolute",visibility:"hidden",display:"block"},Ht={letterSpacing:0,fontWeight:400},At=["Top","Right","Bottom","Left"],qt=["Webkit","O","Moz","ms"];function Ot(e,t){if(t in e)return t;var n=t.charAt(0).toUpperCase()+t.slice(1),r=t,i=qt.length;while(i--)if(t=qt[i]+n,t in e)return t;return r}function Ft(e,t){return e=t||e,"none"===x.css(e,"display")||!x.contains(e.ownerDocument,e)}function Lt(t){return e.getComputedStyle(t,null)}function Pt(e,t){var n,r,i,o=[],s=0,a=e.length;for(;a>s;s++)r=e[s],r.style&&(o[s]=L.get(r,"olddisplay"),n=r.style.display,t?(o[s]||"none"!==n||(r.style.display=""),""===r.style.display&&Ft(r)&&(o[s]=L.access(r,"olddisplay",$t(r.nodeName)))):o[s]||(i=Ft(r),(n&&"none"!==n||!i)&&L.set(r,"olddisplay",i?n:x.css(r,"display"))));for(s=0;a>s;s++)r=e[s],r.style&&(t&&"none"!==r.style.display&&""!==r.style.display||(r.style.display=t?o[s]||"":"none"));return e}x.fn.extend({css:function(e,t){return x.access(this,function(e,t,n){var r,i,o={},s=0;if(x.isArray(t)){for(r=Lt(e),i=t.length;i>s;s++)o[t[s]]=x.css(e,t[s],!1,r);return o}return n!==undefined?x.style(e,t,n):x.css(e,t)},e,t,arguments.length>1)},show:function(){return Pt(this,!0)},hide:function(){return Pt(this)},toggle:function(e){return"boolean"==typeof e?e?this.show():this.hide():this.each(function(){Ft(this)?x(this).show():x(this).hide()})}}),x.extend({cssHooks:{opacity:{get:function(e,t){if(t){var n=wt(e,"opacity");return""===n?"1":n}}}},cssNumber:{columnCount:!0,fillOpacity:!0,fontWeight:!0,lineHeight:!0,opacity:!0,order:!0,orphans:!0,widows:!0,zIndex:!0,zoom:!0},cssProps:{"float":"cssFloat"},style:function(e,t,n,r){if(e&&3!==e.nodeType&&8!==e.nodeType&&e.style){var i,o,s,a=x.camelCase(t),u=e.style;return t=x.cssProps[a]||(x.cssProps[a]=Ot(u,a)),s=x.cssHooks[t]||x.cssHooks[a],n===undefined?s&&"get"in s&&(i=s.get(e,!1,r))!==undefined?i:u[t]:(o=typeof n,"string"===o&&(i=Nt.exec(n))&&(n=(i[1]+1)*i[2]+parseFloat(x.css(e,t)),o="number"),null==n||"number"===o&&isNaN(n)||("number"!==o||x.cssNumber[a]||(n+="px"),x.support.clearCloneStyle||""!==n||0!==t.indexOf("background")||(u[t]="inherit"),s&&"set"in s&&(n=s.set(e,n,r))===undefined||(u[t]=n)),undefined)}},css:function(e,t,n,r){var i,o,s,a=x.camelCase(t);return t=x.cssProps[a]||(x.cssProps[a]=Ot(e.style,a)),s=x.cssHooks[t]||x.cssHooks[a],s&&"get"in s&&(i=s.get(e,!0,n)),i===undefined&&(i=wt(e,t,r)),"normal"===i&&t in Ht&&(i=Ht[t]),""===n||n?(o=parseFloat(i),n===!0||x.isNumeric(o)?o||0:i):i}}),wt=function(e,t,n){var r,i,o,s=n||Lt(e),a=s?s.getPropertyValue(t)||s[t]:undefined,u=e.style;return s&&(""!==a||x.contains(e.ownerDocument,e)||(a=x.style(e,t)),St.test(a)&&Ct.test(t)&&(r=u.width,i=u.minWidth,o=u.maxWidth,u.minWidth=u.maxWidth=u.width=a,a=s.width,u.width=r,u.minWidth=i,u.maxWidth=o)),a};function Mt(e,t,n){var r=jt.exec(t);return r?Math.max(0,r[1]-(n||0))+(r[2]||"px"):t}function Wt(e,t,n,r,i){var o=n===(r?"border":"content")?4:"width"===t?1:0,s=0;for(;4>o;o+=2)"margin"===n&&(s+=x.css(e,n+At[o],!0,i)),r?("content"===n&&(s-=x.css(e,"padding"+At[o],!0,i)),"margin"!==n&&(s-=x.css(e,"border"+At[o]+"Width",!0,i))):(s+=x.css(e,"padding"+At[o],!0,i),"padding"!==n&&(s+=x.css(e,"border"+At[o]+"Width",!0,i)));return s}function Rt(e,t,n){var r=!0,i="width"===t?e.offsetWidth:e.offsetHeight,o=Lt(e),s=x.support.boxSizing&&"border-box"===x.css(e,"boxSizing",!1,o);if(0>=i||null==i){if(i=wt(e,t,o),(0>i||null==i)&&(i=e.style[t]),St.test(i))return i;r=s&&(x.support.boxSizingReliable||i===e.style[t]),i=parseFloat(i)||0}return i+Wt(e,t,n||(s?"border":"content"),r,o)+"px"}function $t(e){var t=o,n=Dt[e];return n||(n=_t(e,t),"none"!==n&&n||(Tt=(Tt||x("<iframe frameborder='0' width='0' height='0'/>").css("cssText","display:block !important")).appendTo(t.documentElement),t=(Tt[0].contentWindow||Tt[0].contentDocument).document,t.write("<!doctype html><html><body>"),t.close(),n=_t(e,t),Tt.detach()),Dt[e]=n),n}function _t(e,t){var n=x(t.createElement(e)).appendTo(t.body),r=x.css(n[0],"display");return n.remove(),r}x.each(["height","width"],function(e,t){x.cssHooks[t]={get:function(e,n,r){return n?0===e.offsetWidth&&kt.test(x.css(e,"display"))?x.swap(e,Et,function(){return Rt(e,t,r)}):Rt(e,t,r):undefined},set:function(e,n,r){var i=r&&Lt(e);return Mt(e,n,r?Wt(e,t,r,x.support.boxSizing&&"border-box"===x.css(e,"boxSizing",!1,i),i):0)}}}),x(function(){x.support.reliableMarginRight||(x.cssHooks.marginRight={get:function(e,t){return t?x.swap(e,{display:"inline-block"},wt,[e,"marginRight"]):undefined}}),!x.support.pixelPosition&&x.fn.position&&x.each(["top","left"],function(e,t){x.cssHooks[t]={get:function(e,n){return n?(n=wt(e,t),St.test(n)?x(e).position()[t]+"px":n):undefined}}})}),x.expr&&x.expr.filters&&(x.expr.filters.hidden=function(e){return 0>=e.offsetWidth&&0>=e.offsetHeight},x.expr.filters.visible=function(e){return!x.expr.filters.hidden(e)}),x.each({margin:"",padding:"",border:"Width"},function(e,t){x.cssHooks[e+t]={expand:function(n){var r=0,i={},o="string"==typeof n?n.split(" "):[n];for(;4>r;r++)i[e+At[r]+t]=o[r]||o[r-2]||o[0];return i}},Ct.test(e)||(x.cssHooks[e+t].set=Mt)});var zt=/%20/g,Xt=/\[\]$/,Bt=/\r?\n/g,It=/^(?:submit|button|image|reset|file)$/i,Ut=/^(?:input|select|textarea|keygen)/i;x.fn.extend({serialize:function(){return x.param(this.serializeArray())},serializeArray:function(){return this.map(function(){var e=x.prop(this,"elements");return e?x.makeArray(e):this}).filter(function(){var e=this.type;return this.name&&!x(this).is(":disabled")&&Ut.test(this.nodeName)&&!It.test(e)&&(this.checked||!ut.test(e))}).map(function(e,t){var n=x(this).val();return null==n?null:x.isArray(n)?x.map(n,function(e){return{name:t.name,value:e.replace(Bt,"\r\n")}}):{name:t.name,value:n.replace(Bt,"\r\n")}}).get()}}),x.param=function(e,t){var n,r=[],i=function(e,t){t=x.isFunction(t)?t():null==t?"":t,r[r.length]=encodeURIComponent(e)+"="+encodeURIComponent(t)};if(t===undefined&&(t=x.ajaxSettings&&x.ajaxSettings.traditional),x.isArray(e)||e.jquery&&!x.isPlainObject(e))x.each(e,function(){i(this.name,this.value)});else for(n in e)Yt(n,e[n],t,i);return r.join("&").replace(zt,"+")};function Yt(e,t,n,r){var i;if(x.isArray(t))x.each(t,function(t,i){n||Xt.test(e)?r(e,i):Yt(e+"["+("object"==typeof i?t:"")+"]",i,n,r)});else if(n||"object"!==x.type(t))r(e,t);else for(i in t)Yt(e+"["+i+"]",t[i],n,r)}x.each("blur focus focusin focusout load resize scroll unload click dblclick mousedown mouseup mousemove mouseover mouseout mouseenter mouseleave change select submit keydown keypress keyup error contextmenu".split(" "),function(e,t){x.fn[t]=function(e,n){return arguments.length>0?this.on(t,null,e,n):this.trigger(t)}}),x.fn.extend({hover:function(e,t){return this.mouseenter(e).mouseleave(t||e)},bind:function(e,t,n){return this.on(e,null,t,n)},unbind:function(e,t){return this.off(e,null,t)},delegate:function(e,t,n,r){return this.on(t,e,n,r)},undelegate:function(e,t,n){return 1===arguments.length?this.off(e,"**"):this.off(t,e||"**",n)}});var Vt,Jt,Qt=x.now(),Gt=/\?/,Kt=/#.*$/,Zt=/([?&])_=[^&]*/,en=/^(.*?):[ \t]*([^\r\n]*)$/gm,tn=/^(?:about|app|app-storage|.+-extension|file|res|widget):$/,nn=/^(?:GET|HEAD)$/,rn=/^\/\//,on=/^([\w.+-]+:)(?:\/\/([^\/?#:]*)(?::(\d+)|)|)/,sn=x.fn.load,an={},un={},cn="*/".concat("*");try{Jt=i.href}catch(ln){Jt=o.createElement("a"),Jt.href="",Jt=Jt.href}Vt=on.exec(Jt.toLowerCase())||[];function pn(e){return function(t,n){"string"!=typeof t&&(n=t,t="*");var r,i=0,o=t.toLowerCase().match(w)||[];if(x.isFunction(n))while(r=o[i++])"+"===r[0]?(r=r.slice(1)||"*",(e[r]=e[r]||[]).unshift(n)):(e[r]=e[r]||[]).push(n)}}function fn(e,t,n,r){var i={},o=e===un;function s(a){var u;return i[a]=!0,x.each(e[a]||[],function(e,a){var c=a(t,n,r);return"string"!=typeof c||o||i[c]?o?!(u=c):undefined:(t.dataTypes.unshift(c),s(c),!1)}),u}return s(t.dataTypes[0])||!i["*"]&&s("*")}function hn(e,t){var n,r,i=x.ajaxSettings.flatOptions||{};for(n in t)t[n]!==undefined&&((i[n]?e:r||(r={}))[n]=t[n]);return r&&x.extend(!0,e,r),e}x.fn.load=function(e,t,n){if("string"!=typeof e&&sn)return sn.apply(this,arguments);var r,i,o,s=this,a=e.indexOf(" ");return a>=0&&(r=e.slice(a),e=e.slice(0,a)),x.isFunction(t)?(n=t,t=undefined):t&&"object"==typeof t&&(i="POST"),s.length>0&&x.ajax({url:e,type:i,dataType:"html",data:t}).done(function(e){o=arguments,s.html(r?x("<div>").append(x.parseHTML(e)).find(r):e)}).complete(n&&function(e,t){s.each(n,o||[e.responseText,t,e])}),this},x.each(["ajaxStart","ajaxStop","ajaxComplete","ajaxError","ajaxSuccess","ajaxSend"],function(e,t){x.fn[t]=function(e){return this.on(t,e)}}),x.extend({active:0,lastModified:{},etag:{},ajaxSettings:{url:Jt,type:"GET",isLocal:tn.test(Vt[1]),global:!0,processData:!0,async:!0,contentType:"application/x-www-form-urlencoded; charset=UTF-8",accepts:{"*":cn,text:"text/plain",html:"text/html",xml:"application/xml, text/xml",json:"application/json, text/javascript"},contents:{xml:/xml/,html:/html/,json:/json/},responseFields:{xml:"responseXML",text:"responseText",json:"responseJSON"},converters:{"* text":String,"text html":!0,"text json":x.parseJSON,"text xml":x.parseXML},flatOptions:{url:!0,context:!0}},ajaxSetup:function(e,t){return t?hn(hn(e,x.ajaxSettings),t):hn(x.ajaxSettings,e)},ajaxPrefilter:pn(an),ajaxTransport:pn(un),ajax:function(e,t){"object"==typeof e&&(t=e,e=undefined),t=t||{};var n,r,i,o,s,a,u,c,l=x.ajaxSetup({},t),p=l.context||l,f=l.context&&(p.nodeType||p.jquery)?x(p):x.event,h=x.Deferred(),d=x.Callbacks("once memory"),g=l.statusCode||{},m={},y={},v=0,b="canceled",T={readyState:0,getResponseHeader:function(e){var t;if(2===v){if(!o){o={};while(t=en.exec(i))o[t[1].toLowerCase()]=t[2]}t=o[e.toLowerCase()]}return null==t?null:t},getAllResponseHeaders:function(){return 2===v?i:null},setRequestHeader:function(e,t){var n=e.toLowerCase();return v||(e=y[n]=y[n]||e,m[e]=t),this},overrideMimeType:function(e){return v||(l.mimeType=e),this},statusCode:function(e){var t;if(e)if(2>v)for(t in e)g[t]=[g[t],e[t]];else T.always(e[T.status]);return this},abort:function(e){var t=e||b;return n&&n.abort(t),C(0,t),this}};if(h.promise(T).complete=d.add,T.success=T.done,T.error=T.fail,l.url=((e||l.url||Jt)+"").replace(Kt,"").replace(rn,Vt[1]+"//"),l.type=t.method||t.type||l.method||l.type,l.dataTypes=x.trim(l.dataType||"*").toLowerCase().match(w)||[""],null==l.crossDomain&&(a=on.exec(l.url.toLowerCase()),l.crossDomain=!(!a||a[1]===Vt[1]&&a[2]===Vt[2]&&(a[3]||("http:"===a[1]?"80":"443"))===(Vt[3]||("http:"===Vt[1]?"80":"443")))),l.data&&l.processData&&"string"!=typeof l.data&&(l.data=x.param(l.data,l.traditional)),fn(an,l,t,T),2===v)return T;u=l.global,u&&0===x.active++&&x.event.trigger("ajaxStart"),l.type=l.type.toUpperCase(),l.hasContent=!nn.test(l.type),r=l.url,l.hasContent||(l.data&&(r=l.url+=(Gt.test(r)?"&":"?")+l.data,delete l.data),l.cache===!1&&(l.url=Zt.test(r)?r.replace(Zt,"$1_="+Qt++):r+(Gt.test(r)?"&":"?")+"_="+Qt++)),l.ifModified&&(x.lastModified[r]&&T.setRequestHeader("If-Modified-Since",x.lastModified[r]),x.etag[r]&&T.setRequestHeader("If-None-Match",x.etag[r])),(l.data&&l.hasContent&&l.contentType!==!1||t.contentType)&&T.setRequestHeader("Content-Type",l.contentType),T.setRequestHeader("Accept",l.dataTypes[0]&&l.accepts[l.dataTypes[0]]?l.accepts[l.dataTypes[0]]+("*"!==l.dataTypes[0]?", "+cn+"; q=0.01":""):l.accepts["*"]);for(c in l.headers)T.setRequestHeader(c,l.headers[c]);if(l.beforeSend&&(l.beforeSend.call(p,T,l)===!1||2===v))return T.abort();b="abort";for(c in{success:1,error:1,complete:1})T[c](l[c]);if(n=fn(un,l,t,T)){T.readyState=1,u&&f.trigger("ajaxSend",[T,l]),l.async&&l.timeout>0&&(s=setTimeout(function(){T.abort("timeout")},l.timeout));try{v=1,n.send(m,C)}catch(k){if(!(2>v))throw k;C(-1,k)}}else C(-1,"No Transport");function C(e,t,o,a){var c,m,y,b,w,k=t;2!==v&&(v=2,s&&clearTimeout(s),n=undefined,i=a||"",T.readyState=e>0?4:0,c=e>=200&&300>e||304===e,o&&(b=dn(l,T,o)),b=gn(l,b,T,c),c?(l.ifModified&&(w=T.getResponseHeader("Last-Modified"),w&&(x.lastModified[r]=w),w=T.getResponseHeader("etag"),w&&(x.etag[r]=w)),204===e||"HEAD"===l.type?k="nocontent":304===e?k="notmodified":(k=b.state,m=b.data,y=b.error,c=!y)):(y=k,(e||!k)&&(k="error",0>e&&(e=0))),T.status=e,T.statusText=(t||k)+"",c?h.resolveWith(p,[m,k,T]):h.rejectWith(p,[T,k,y]),T.statusCode(g),g=undefined,u&&f.trigger(c?"ajaxSuccess":"ajaxError",[T,l,c?m:y]),d.fireWith(p,[T,k]),u&&(f.trigger("ajaxComplete",[T,l]),--x.active||x.event.trigger("ajaxStop")))}return T},getJSON:function(e,t,n){return x.get(e,t,n,"json")},getScript:function(e,t){return x.get(e,undefined,t,"script")}}),x.each(["get","post"],function(e,t){x[t]=function(e,n,r,i){return x.isFunction(n)&&(i=i||r,r=n,n=undefined),x.ajax({url:e,type:t,dataType:i,data:n,success:r})}});function dn(e,t,n){var r,i,o,s,a=e.contents,u=e.dataTypes;while("*"===u[0])u.shift(),r===undefined&&(r=e.mimeType||t.getResponseHeader("Content-Type"));if(r)for(i in a)if(a[i]&&a[i].test(r)){u.unshift(i);break}if(u[0]in n)o=u[0];else{for(i in n){if(!u[0]||e.converters[i+" "+u[0]]){o=i;break}s||(s=i)}o=o||s}return o?(o!==u[0]&&u.unshift(o),n[o]):undefined}function gn(e,t,n,r){var i,o,s,a,u,c={},l=e.dataTypes.slice();if(l[1])for(s in e.converters)c[s.toLowerCase()]=e.converters[s];o=l.shift();while(o)if(e.responseFields[o]&&(n[e.responseFields[o]]=t),!u&&r&&e.dataFilter&&(t=e.dataFilter(t,e.dataType)),u=o,o=l.shift())if("*"===o)o=u;else if("*"!==u&&u!==o){if(s=c[u+" "+o]||c["* "+o],!s)for(i in c)if(a=i.split(" "),a[1]===o&&(s=c[u+" "+a[0]]||c["* "+a[0]])){s===!0?s=c[i]:c[i]!==!0&&(o=a[0],l.unshift(a[1]));break}if(s!==!0)if(s&&e["throws"])t=s(t);else try{t=s(t)}catch(p){return{state:"parsererror",error:s?p:"No conversion from "+u+" to "+o}}}return{state:"success",data:t}}x.ajaxSetup({accepts:{script:"text/javascript, application/javascript, application/ecmascript, application/x-ecmascript"},contents:{script:/(?:java|ecma)script/},converters:{"text script":function(e){return x.globalEval(e),e}}}),x.ajaxPrefilter("script",function(e){e.cache===undefined&&(e.cache=!1),e.crossDomain&&(e.type="GET")}),x.ajaxTransport("script",function(e){if(e.crossDomain){var t,n;return{send:function(r,i){t=x("<script>").prop({async:!0,charset:e.scriptCharset,src:e.url}).on("load error",n=function(e){t.remove(),n=null,e&&i("error"===e.type?404:200,e.type)}),o.head.appendChild(t[0])},abort:function(){n&&n()}}}});var mn=[],yn=/(=)\?(?=&|$)|\?\?/;x.ajaxSetup({jsonp:"callback",jsonpCallback:function(){var e=mn.pop()||x.expando+"_"+Qt++;return this[e]=!0,e}}),x.ajaxPrefilter("json jsonp",function(t,n,r){var i,o,s,a=t.jsonp!==!1&&(yn.test(t.url)?"url":"string"==typeof t.data&&!(t.contentType||"").indexOf("application/x-www-form-urlencoded")&&yn.test(t.data)&&"data");return a||"jsonp"===t.dataTypes[0]?(i=t.jsonpCallback=x.isFunction(t.jsonpCallback)?t.jsonpCallback():t.jsonpCallback,a?t[a]=t[a].replace(yn,"$1"+i):t.jsonp!==!1&&(t.url+=(Gt.test(t.url)?"&":"?")+t.jsonp+"="+i),t.converters["script json"]=function(){return s||x.error(i+" was not called"),s[0]},t.dataTypes[0]="json",o=e[i],e[i]=function(){s=arguments},r.always(function(){e[i]=o,t[i]&&(t.jsonpCallback=n.jsonpCallback,mn.push(i)),s&&x.isFunction(o)&&o(s[0]),s=o=undefined}),"script"):undefined}),x.ajaxSettings.xhr=function(){try{return new XMLHttpRequest}catch(e){}};var vn=x.ajaxSettings.xhr(),xn={0:200,1223:204},bn=0,wn={};e.ActiveXObject&&x(e).on("unload",function(){for(var e in wn)wn[e]();wn=undefined}),x.support.cors=!!vn&&"withCredentials"in vn,x.support.ajax=vn=!!vn,x.ajaxTransport(function(e){var t;return x.support.cors||vn&&!e.crossDomain?{send:function(n,r){var i,o,s=e.xhr();if(s.open(e.type,e.url,e.async,e.username,e.password),e.xhrFields)for(i in e.xhrFields)s[i]=e.xhrFields[i];e.mimeType&&s.overrideMimeType&&s.overrideMimeType(e.mimeType),e.crossDomain||n["X-Requested-With"]||(n["X-Requested-With"]="XMLHttpRequest");for(i in n)s.setRequestHeader(i,n[i]);t=function(e){return function(){t&&(delete wn[o],t=s.onload=s.onerror=null,"abort"===e?s.abort():"error"===e?r(s.status||404,s.statusText):r(xn[s.status]||s.status,s.statusText,"string"==typeof s.responseText?{text:s.responseText}:undefined,s.getAllResponseHeaders()))}},s.onload=t(),s.onerror=t("error"),t=wn[o=bn++]=t("abort"),s.send(e.hasContent&&e.data||null)},abort:function(){t&&t()}}:undefined});var Tn,kn,Cn=/^(?:toggle|show|hide)$/,jn=RegExp("^(?:([+-])=|)("+b+")([a-z%]*)$","i"),Sn=/queueHooks$/,Nn=[On],Dn={"*":[function(e,t){var n=this.createTween(e,t),r=n.cur(),i=jn.exec(t),o=i&&i[3]||(x.cssNumber[e]?"":"px"),s=(x.cssNumber[e]||"px"!==o&&+r)&&jn.exec(x.css(n.elem,e)),a=1,u=20;if(s&&s[3]!==o){o=o||s[3],i=i||[],s=+r||1;do a=a||".5",s/=a,x.style(n.elem,e,s+o);while(a!==(a=n.cur()/r)&&1!==a&&--u)}return i&&(s=n.start=+s||+r||0,n.unit=o,n.end=i[1]?s+(i[1]+1)*i[2]:+i[2]),n}]};function En(){return setTimeout(function(){Tn=undefined}),Tn=x.now()}function Hn(e,t,n){var r,i=(Dn[t]||[]).concat(Dn["*"]),o=0,s=i.length;for(;s>o;o++)if(r=i[o].call(n,t,e))return r}function An(e,t,n){var r,i,o=0,s=Nn.length,a=x.Deferred().always(function(){delete u.elem}),u=function(){if(i)return!1;var t=Tn||En(),n=Math.max(0,c.startTime+c.duration-t),r=n/c.duration||0,o=1-r,s=0,u=c.tweens.length;for(;u>s;s++)c.tweens[s].run(o);return a.notifyWith(e,[c,o,n]),1>o&&u?n:(a.resolveWith(e,[c]),!1)},c=a.promise({elem:e,props:x.extend({},t),opts:x.extend(!0,{specialEasing:{}},n),originalProperties:t,originalOptions:n,startTime:Tn||En(),duration:n.duration,tweens:[],createTween:function(t,n){var r=x.Tween(e,c.opts,t,n,c.opts.specialEasing[t]||c.opts.easing);return c.tweens.push(r),r},stop:function(t){var n=0,r=t?c.tweens.length:0;if(i)return this;for(i=!0;r>n;n++)c.tweens[n].run(1);return t?a.resolveWith(e,[c,t]):a.rejectWith(e,[c,t]),this}}),l=c.props;for(qn(l,c.opts.specialEasing);s>o;o++)if(r=Nn[o].call(c,e,l,c.opts))return r;return x.map(l,Hn,c),x.isFunction(c.opts.start)&&c.opts.start.call(e,c),x.fx.timer(x.extend(u,{elem:e,anim:c,queue:c.opts.queue})),c.progress(c.opts.progress).done(c.opts.done,c.opts.complete).fail(c.opts.fail).always(c.opts.always)}function qn(e,t){var n,r,i,o,s;for(n in e)if(r=x.camelCase(n),i=t[r],o=e[n],x.isArray(o)&&(i=o[1],o=e[n]=o[0]),n!==r&&(e[r]=o,delete e[n]),s=x.cssHooks[r],s&&"expand"in s){o=s.expand(o),delete e[r];for(n in o)n in e||(e[n]=o[n],t[n]=i)}else t[r]=i}x.Animation=x.extend(An,{tweener:function(e,t){x.isFunction(e)?(t=e,e=["*"]):e=e.split(" ");var n,r=0,i=e.length;for(;i>r;r++)n=e[r],Dn[n]=Dn[n]||[],Dn[n].unshift(t)},prefilter:function(e,t){t?Nn.unshift(e):Nn.push(e)}});function On(e,t,n){var r,i,o,s,a,u,c=this,l={},p=e.style,f=e.nodeType&&Ft(e),h=L.get(e,"fxshow");n.queue||(a=x._queueHooks(e,"fx"),null==a.unqueued&&(a.unqueued=0,u=a.empty.fire,a.empty.fire=function(){a.unqueued||u()}),a.unqueued++,c.always(function(){c.always(function(){a.unqueued--,x.queue(e,"fx").length||a.empty.fire()})})),1===e.nodeType&&("height"in t||"width"in t)&&(n.overflow=[p.overflow,p.overflowX,p.overflowY],"inline"===x.css(e,"display")&&"none"===x.css(e,"float")&&(p.display="inline-block")),n.overflow&&(p.overflow="hidden",c.always(function(){p.overflow=n.overflow[0],p.overflowX=n.overflow[1],p.overflowY=n.overflow[2]}));for(r in t)if(i=t[r],Cn.exec(i)){if(delete t[r],o=o||"toggle"===i,i===(f?"hide":"show")){if("show"!==i||!h||h[r]===undefined)continue;f=!0}l[r]=h&&h[r]||x.style(e,r)}if(!x.isEmptyObject(l)){h?"hidden"in h&&(f=h.hidden):h=L.access(e,"fxshow",{}),o&&(h.hidden=!f),f?x(e).show():c.done(function(){x(e).hide()}),c.done(function(){var t;L.remove(e,"fxshow");for(t in l)x.style(e,t,l[t])});for(r in l)s=Hn(f?h[r]:0,r,c),r in h||(h[r]=s.start,f&&(s.end=s.start,s.start="width"===r||"height"===r?1:0))}}function Fn(e,t,n,r,i){return new Fn.prototype.init(e,t,n,r,i)}x.Tween=Fn,Fn.prototype={constructor:Fn,init:function(e,t,n,r,i,o){this.elem=e,this.prop=n,this.easing=i||"swing",this.options=t,this.start=this.now=this.cur(),this.end=r,this.unit=o||(x.cssNumber[n]?"":"px")},cur:function(){var e=Fn.propHooks[this.prop];return e&&e.get?e.get(this):Fn.propHooks._default.get(this)},run:function(e){var t,n=Fn.propHooks[this.prop];return this.pos=t=this.options.duration?x.easing[this.easing](e,this.options.duration*e,0,1,this.options.duration):e,this.now=(this.end-this.start)*t+this.start,this.options.step&&this.options.step.call(this.elem,this.now,this),n&&n.set?n.set(this):Fn.propHooks._default.set(this),this}},Fn.prototype.init.prototype=Fn.prototype,Fn.propHooks={_default:{get:function(e){var t;return null==e.elem[e.prop]||e.elem.style&&null!=e.elem.style[e.prop]?(t=x.css(e.elem,e.prop,""),t&&"auto"!==t?t:0):e.elem[e.prop]},set:function(e){x.fx.step[e.prop]?x.fx.step[e.prop](e):e.elem.style&&(null!=e.elem.style[x.cssProps[e.prop]]||x.cssHooks[e.prop])?x.style(e.elem,e.prop,e.now+e.unit):e.elem[e.prop]=e.now}}},Fn.propHooks.scrollTop=Fn.propHooks.scrollLeft={set:function(e){e.elem.nodeType&&e.elem.parentNode&&(e.elem[e.prop]=e.now)}},x.each(["toggle","show","hide"],function(e,t){var n=x.fn[t];x.fn[t]=function(e,r,i){return null==e||"boolean"==typeof e?n.apply(this,arguments):this.animate(Ln(t,!0),e,r,i)}}),x.fn.extend({fadeTo:function(e,t,n,r){return this.filter(Ft).css("opacity",0).show().end().animate({opacity:t},e,n,r)},animate:function(e,t,n,r){var i=x.isEmptyObject(e),o=x.speed(t,n,r),s=function(){var t=An(this,x.extend({},e),o);(i||L.get(this,"finish"))&&t.stop(!0)};return s.finish=s,i||o.queue===!1?this.each(s):this.queue(o.queue,s)},stop:function(e,t,n){var r=function(e){var t=e.stop;delete e.stop,t(n)};return"string"!=typeof e&&(n=t,t=e,e=undefined),t&&e!==!1&&this.queue(e||"fx",[]),this.each(function(){var t=!0,i=null!=e&&e+"queueHooks",o=x.timers,s=L.get(this);if(i)s[i]&&s[i].stop&&r(s[i]);else for(i in s)s[i]&&s[i].stop&&Sn.test(i)&&r(s[i]);for(i=o.length;i--;)o[i].elem!==this||null!=e&&o[i].queue!==e||(o[i].anim.stop(n),t=!1,o.splice(i,1));(t||!n)&&x.dequeue(this,e)})},finish:function(e){return e!==!1&&(e=e||"fx"),this.each(function(){var t,n=L.get(this),r=n[e+"queue"],i=n[e+"queueHooks"],o=x.timers,s=r?r.length:0;for(n.finish=!0,x.queue(this,e,[]),i&&i.stop&&i.stop.call(this,!0),t=o.length;t--;)o[t].elem===this&&o[t].queue===e&&(o[t].anim.stop(!0),o.splice(t,1));for(t=0;s>t;t++)r[t]&&r[t].finish&&r[t].finish.call(this);delete n.finish})}});function Ln(e,t){var n,r={height:e},i=0;for(t=t?1:0;4>i;i+=2-t)n=At[i],r["margin"+n]=r["padding"+n]=e;return t&&(r.opacity=r.width=e),r}x.each({slideDown:Ln("show"),slideUp:Ln("hide"),slideToggle:Ln("toggle"),fadeIn:{opacity:"show"},fadeOut:{opacity:"hide"},fadeToggle:{opacity:"toggle"}},function(e,t){x.fn[e]=function(e,n,r){return this.animate(t,e,n,r)}}),x.speed=function(e,t,n){var r=e&&"object"==typeof e?x.extend({},e):{complete:n||!n&&t||x.isFunction(e)&&e,duration:e,easing:n&&t||t&&!x.isFunction(t)&&t};return r.duration=x.fx.off?0:"number"==typeof r.duration?r.duration:r.duration in x.fx.speeds?x.fx.speeds[r.duration]:x.fx.speeds._default,(null==r.queue||r.queue===!0)&&(r.queue="fx"),r.old=r.complete,r.complete=function(){x.isFunction(r.old)&&r.old.call(this),r.queue&&x.dequeue(this,r.queue)},r},x.easing={linear:function(e){return e},swing:function(e){return.5-Math.cos(e*Math.PI)/2}},x.timers=[],x.fx=Fn.prototype.init,x.fx.tick=function(){var e,t=x.timers,n=0;for(Tn=x.now();t.length>n;n++)e=t[n],e()||t[n]!==e||t.splice(n--,1);t.length||x.fx.stop(),Tn=undefined},x.fx.timer=function(e){e()&&x.timers.push(e)&&x.fx.start()},x.fx.interval=13,x.fx.start=function(){kn||(kn=setInterval(x.fx.tick,x.fx.interval))
                },x.fx.stop=function(){clearInterval(kn),kn=null},x.fx.speeds={slow:600,fast:200,_default:400},x.fx.step={},x.expr&&x.expr.filters&&(x.expr.filters.animated=function(e){return x.grep(x.timers,function(t){return e===t.elem}).length}),x.fn.offset=function(e){if(arguments.length)return e===undefined?this:this.each(function(t){x.offset.setOffset(this,e,t)});var t,n,i=this[0],o={top:0,left:0},s=i&&i.ownerDocument;if(s)return t=s.documentElement,x.contains(t,i)?(typeof i.getBoundingClientRect!==r&&(o=i.getBoundingClientRect()),n=Pn(s),{top:o.top+n.pageYOffset-t.clientTop,left:o.left+n.pageXOffset-t.clientLeft}):o},x.offset={setOffset:function(e,t,n){var r,i,o,s,a,u,c,l=x.css(e,"position"),p=x(e),f={};"static"===l&&(e.style.position="relative"),a=p.offset(),o=x.css(e,"top"),u=x.css(e,"left"),c=("absolute"===l||"fixed"===l)&&(o+u).indexOf("auto")>-1,c?(r=p.position(),s=r.top,i=r.left):(s=parseFloat(o)||0,i=parseFloat(u)||0),x.isFunction(t)&&(t=t.call(e,n,a)),null!=t.top&&(f.top=t.top-a.top+s),null!=t.left&&(f.left=t.left-a.left+i),"using"in t?t.using.call(e,f):p.css(f)}},x.fn.extend({position:function(){if(this[0]){var e,t,n=this[0],r={top:0,left:0};return"fixed"===x.css(n,"position")?t=n.getBoundingClientRect():(e=this.offsetParent(),t=this.offset(),x.nodeName(e[0],"html")||(r=e.offset()),r.top+=x.css(e[0],"borderTopWidth",!0),r.left+=x.css(e[0],"borderLeftWidth",!0)),{top:t.top-r.top-x.css(n,"marginTop",!0),left:t.left-r.left-x.css(n,"marginLeft",!0)}}},offsetParent:function(){return this.map(function(){var e=this.offsetParent||s;while(e&&!x.nodeName(e,"html")&&"static"===x.css(e,"position"))e=e.offsetParent;return e||s})}}),x.each({scrollLeft:"pageXOffset",scrollTop:"pageYOffset"},function(t,n){var r="pageYOffset"===n;x.fn[t]=function(i){return x.access(this,function(t,i,o){var s=Pn(t);return o===undefined?s?s[n]:t[i]:(s?s.scrollTo(r?e.pageXOffset:o,r?o:e.pageYOffset):t[i]=o,undefined)},t,i,arguments.length,null)}});function Pn(e){return x.isWindow(e)?e:9===e.nodeType&&e.defaultView}x.each({Height:"height",Width:"width"},function(e,t){x.each({padding:"inner"+e,content:t,"":"outer"+e},function(n,r){x.fn[r]=function(r,i){var o=arguments.length&&(n||"boolean"!=typeof r),s=n||(r===!0||i===!0?"margin":"border");return x.access(this,function(t,n,r){var i;return x.isWindow(t)?t.document.documentElement["client"+e]:9===t.nodeType?(i=t.documentElement,Math.max(t.body["scroll"+e],i["scroll"+e],t.body["offset"+e],i["offset"+e],i["client"+e])):r===undefined?x.css(t,n,s):x.style(t,n,r,s)},t,o?r:undefined,o,null)}})}),"object"==typeof module&&module&&"object"==typeof module.exports?module.exports=x:"function"==typeof define&&define.amd&&define("jquery",[],function(){return x}),"object"==typeof e&&"object"==typeof e.document&&(e.jQuery=e.$=x)})(window);
                jq = jQuery.noConflict();
            }

            jq.ajaxSetup({
                cache: true,
                async: true,
                traditional: false,
                xhrFields: {
                    withCredentials: true
                }
            });
        }

        var animationSupport = function() {

            var thisBody = document.body || document.documentElement,
                thisStyle = thisBody.style,
                support = thisStyle.transition !== undefined || thisStyle.WebkitTransition !== undefined || thisStyle.MozTransition !== undefined || thisStyle.MsTransition !== undefined || thisStyle.OTransition !== undefined;
                return support;
        };

        var getBrowserPrefix = function() {
   
            // Check for the unprefixed property.
            if ('hidden' in document) {
                return null;
            }
 
            // All the possible prefixes.
            var browserPrefixes = ['moz', 'ms', 'o', 'webkit'];

            for (var i = 0; i < browserPrefixes.length; i++) {
                var prefix = browserPrefixes[i] + 'Hidden';
                if (prefix in document) {
                  return browserPrefixes[i];
                }
            }

            return null;
        }
 
        var hiddenProperty = function(prefix) {
            if (prefix) {
                return prefix + 'Hidden';
            } else {
                return 'hidden';
            }
        }
 
        var visibilityEvent = function(prefix) {
            if (prefix) {
                return prefix + 'visibilitychange';
            } else {
                return 'visibilitychange';
            }
        }

        var registerEventMessages = function() {
            jq(window).bind('message', function(e) {
                if (!e.originalEvent || !e.originalEvent.data || !e.originalEvent.origin || !rp.chat.Core.getRPDomain() || !rp.chat.Core.getRPDomain('dialog')) {
                    return;
                }

                if (rp.chat.Core.getRPDomain().replace('/system', '') !== e.originalEvent.origin && rp.chat.Core.getRPDomain('dialog').replace('/system', '') !== e.originalEvent.origin) {
                    return;
                }

                var data = e.originalEvent.data;
                switch (data.type) {
                    case 'changeElementHeightRelative':
                        jq(data.id).height(jq(data.id).height() + data.size);
                        break;
                    default:
                        break;
                }
            });
        }

        var triggerEvent = function(el, type, payload) {
            var e = document.createEvent("CustomEvent");
            e.initCustomEvent(type, true, true, payload);
            el.dispatchEvent(e);
        }

        var prefix = getBrowserPrefix();
        var hidden = hiddenProperty(prefix);
        var visibilityEvent = visibilityEvent(prefix);
        var tabActive = 1;

        if (typeof document[hidden] !== "undefined") {
            document.addEventListener(visibilityEvent, function() {
                if (!document[hidden]) {
                    tabActive = 1;
                    if (jq("#optiRealPersonChatContent").length == 1) {
                        rp.chat.Core.loadLayerChatModule();
                    }
                } else {
                    tabActive = 0;
                }
            });
        }

    }

    this.detectAdBlock = function(counter) {

         if (counter == 0) {
            loadJQuery();
            isValidCookieSession();
        }
        counter = counter + 1;
        if ((typeof rp.chat.AdBlockModul === 'undefined') || ((typeof rp.chat.AdBlockModul !== 'undefined') && rp.chat.AdBlock.isBrowserChecked()) || counter == 6) {
            if (typeof rp.chat.AdBlockModul !== 'undefined') {
                if (counter == 6) {
                    rp.chat.AdBlock.setAbortDetection();
                }
                adBlockDetected = rp.chat.AdBlock.isAdBlockDetected();
            }
            hasAdBlockDetected = 1;
        } else {
            window.setTimeout("rp.chat.Core.detectAdBlock(" + counter + ")", 100);
        }
    }
    
    this.setRpFp = function() {
        rp.chat.Core.getJQ().ajax({
            dataType: rp.chat.Core.AjaxDataType,
            type: 'post',
            cache: false,
            url: urlCollect + "/scripts/setRpFp.php",
            data: { deptid:rp.chat.Core.getDeptId(), session_rp:rp.chat.Core.getSessionRp(), sid_opti:rp.chat.Core.getSidOpti(), rpfp:rp.chat.Core.getFp() },
        }).done(function(data) {
        }).fail(function(XMLHttpRequest, textStatus, errorThrown) {});

        return false;
    }

    loadJQuery();
    isValidCookieSession();
    this.loadConfig();
    registerEventMessages();
};

rp.chat.ChatModul = function() {

    prototype:{
        var chat = null;

        this.startPopupChat = function(invitetyp, kind, config, autoinviteRulesId) {
            var title = "", params = "";
            var url = rp.chat.Core.getRPDomain('dialog') + "/redirect.php?action=offlineurl&session_rp=" + rp.chat.Core.getSessionRp() + "&deptid=" + rp.chat.Core.getDeptId();

            if (config.onlinestatus || !invitetyp || (!config.onlinestatus && invitetyp && (typeof config.offlineUrl === 'undefined'))) {
                params = 'location=no,menubar=no,scrollbars=no,resizable=1,screenX=50,screenY=100,width=' + this.getChatWidth() + ',height=' + this.getChatHeight();
                title = rp.chat.Core.getSidOpti();
                url =  rp.chat.Core.getRPDomain('dialog') + "/order.php?pageurl=" + rp.chat.Core.getCurrentUrl() + "&deptid=" + rp.chat.Core.getDeptId() + "&session_rp=" + rp.chat.Core.getSessionRp() + "&pagename=" + rp.chat.Core.getPagename() + '&invitetyp=' + invitetyp + '&chat_type=' + kind + '&sid_opti='+ rp.chat.Core.getSidOpti() + '&adblock_detected=' + rp.chat.Core.getAdBlockDetected() + '&autoinviterulesid=' + autoinviteRulesId + '&iswebrtc=' + rp.chat.Core.getWebRTCDetected() + '&rpfp=' + rp.chat.Core.getFp();
            }
            chat = window.open(url, title, params);
        }

        this.startMobileChat = function(invitetyp, kind, config, autoinviteRulesId) {
            var url = rp.chat.Core.getRPDomain('dialog') + "/redirect.php?action=offlineurl&session_rp=" + rp.chat.Core.getSessionRp() + '&deptid=' + rp.chat.Core.getDeptId();
            if (config.onlinestatus || !invitetyp || (!config.onlinestatus && invitetyp && (typeof config.offlineUrl === 'undefined'))) {
                url = rp.chat.Core.getRPDomain('dialog') + "/mobile/order.php?pageurl=" + rp.chat.Core.getCurrentUrl() + "&deptid=" + rp.chat.Core.getDeptId() + "&session_rp=" + rp.chat.Core.getSessionRp() + "&pagename=" + rp.chat.Core.getPagename() + "&invitetyp=" + invitetyp + "&chat_type=" + kind + "&sid_opti=" + rp.chat.Core.getSidOpti() + "&adblock_detected=" + rp.chat.Core.getAdBlockDetected() + "&autoinviterulesid=" + autoinviteRulesId + "&rpfp=" + rp.chat.Core.getFp();
            }
            chat = window.open(url);
        }

        this.getChatWidth = function() {
            var config = rp.chat.Core.getConfig();
            return (typeof config.chatWindow !== "undefined" && typeof config.chatWindow.size !== "undefined" && typeof config.chatWindow.size.width !== "undefined") ? config.chatWindow.size.width : 450;
        }

        this.getChatHeight = function() {
            var config = rp.chat.Core.getConfig();
            var size = (typeof config.chatWindow !== "undefined" && typeof config.chatWindow.size !== "undefined" && typeof config.chatWindow.size.height !== "undefined") ? config.chatWindow.size.height : 430;
            return (!this.checkBrowserForSafari()) ? size : 350;
        }

        this.checkBrowserForSafari = function() {
            var browser = navigator.userAgent.toLowerCase(); 
            return (browser.indexOf('safari') !== -1 && browser.indexOf('chrome') === -1);
        }

        this.getCurrentAutoinviteRulesId = function(inviteType) {
            if (inviteType == 0 && rp.chat.Core.getJQ()('#InviteImageRealPerson').length) {
                return rp.chat.Core.getJQ()('#InviteImageRealPerson').data('rulesid');
            }
            return 0;
        }

    }
};

if (rp.chat.isInitiated === false) {
    rp.chat.loadModules();
}
