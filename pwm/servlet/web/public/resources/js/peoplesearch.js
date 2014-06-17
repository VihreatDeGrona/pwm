/*
 * Password Management Servlets (PWM)
 * http://code.google.com/p/pwm/
 *
 * Copyright (c) 2006-2009 Novell, Inc.
 * Copyright (c) 2009-2014 The PWM Project
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


"use strict";

var PWM_PS = PWM_PS || {};
var PWM_VAR = PWM_VAR || {};

PWM_PS.processPeopleSearch = function() {
    var validationProps = {};
    validationProps['serviceURL'] = "PeopleSearch?processAction=search";
    validationProps['showMessage'] = false;
    validationProps['ajaxTimeout'] = 120 * 1000;
    validationProps['usernameField'] = PWM_MAIN.getObject('username').value;
    validationProps['readDataFunction'] = function(){
        PWM_MAIN.getObject('searchIndicator').style.visibility = 'visible';
        return { username:PWM_MAIN.getObject('username').value }
    };
    validationProps['completeFunction'] = function() {
        PWM_MAIN.getObject('searchIndicator').style.visibility = 'hidden';
    };
    validationProps['processResultsFunction'] = function(data) {
        var grid = PWM_VAR['peoplesearch_search_grid'];
        if (data['error']) {
            PWM_MAIN.showError("error: " + data['errorMessage']);
            grid.refresh();
        } else {
            var gridData = data['data']['searchResults'];
            var sizeExceeded = data['data']['sizeExceeded'];
            grid.refresh();
            grid.renderArray(gridData);
            grid.on(".dgrid-row:click", function(evt){
                var row = grid.row(evt);
                var userKey = row.data['userKey'];
                PWM_PS.showUserDetail(userKey);
            });
            grid.set("sort",1);
            if (sizeExceeded) {
                PWM_MAIN.getObject('maxResultsIndicator').style.visibility = 'visible';
                PWM_MAIN.showTooltip({id:'maxResultsIndicator',position:'below',text:PWM_MAIN.showString('Display_SearchResultsExceeded')})
            } else {
                PWM_MAIN.getObject('maxResultsIndicator').style.visibility = 'hidden';
            }
        }
    };
    PWM_MAIN.pwmFormValidator(validationProps);
    PWM_MAIN.getObject('maxResultsIndicator').style.visibility = 'hidden';
};

PWM_PS.convertDataResultToHtml = function(data) {
    var htmlBody = '';
    if (data['photoURL']) {
        var blankSrc = PWM_MAIN.addPwmFormIDtoURL(PWM_GLOBAL['url-resources'] + '/dojo/dojo/resources/blank.gif');
        var styleAttr = PWM_VAR['photo_style_attribute'];
        htmlBody += '<div id="userPhotoParentDiv"><img style="' + styleAttr + '" src="' + blankSrc + '"></div>';
    }
    htmlBody += '<table style="max-height: 450px; overflow-y: auto">';
    for (var iter in data['detail']) {
        (function(iterCount){
            var attributeData = data['detail'][iterCount];
            var label = attributeData['label'];
            var type = attributeData['type'];
            htmlBody += '<tr><td class="key">' + label + '</td><td>';

            if (type == 'userDN') {
                var userReferences = attributeData['userReferences'];
                htmlBody += '<div style="max-height: 100px; overflow-y: auto">';
                for (var refIter in userReferences) {
                    (function(refIterInner){
                        var reference = userReferences[refIterInner];
                        var userKey = reference['userKey'];
                        var displayValue = reference['display'];
                        htmlBody += '<a onclick="PWM_PS.showUserDetail(\'' + userKey + '\')">';
                        htmlBody += displayValue;
                        htmlBody += "</a><br/>";
                    })(refIter);
                }
                htmlBody += '</div>';
            } else if (type == 'email') {
                var value = attributeData['value'];
                htmlBody += '<a href="mailto:' + value + '">' + value + '</a>';
            } else {
                htmlBody += attributeData['value']
            }
            htmlBody += '</td>'
        })(iter);
    }
    htmlBody += '</table>';
    return htmlBody;
};

PWM_PS.showUserDetail = function(userKey) {
    var sendData = {
        userKey:userKey
    };
    PWM_MAIN.showWaitDialog({
        loadFunction:function(){
            require(["dojo", "dojo/json"], function (dojo, json) {
                var bodyString = dojo.toJson(sendData);
                dojo.xhrPost({
                    url: "PeopleSearch?processAction=detail&pwmFormID=" + PWM_GLOBAL['pwmFormID'],
                    headers: {"Accept":"application/json","X-RestClientKey":PWM_GLOBAL['restClientKey']},
                    contentType: "application/json;charset=utf-8",
                    encoding: "utf-8",
                    handleAs: "json",
                    dataType: "json",
                    postData: bodyString,
                    error: function (errorObj) {
                        PWM_MAIN.showError("error loading " + userKey + ", reason: " + errorObj)
                        PWM_MAIN.closeWaitDialog();
                    },
                    load: function (data) {
                        if (data['error'] == true) {
                            console.error('unable to load people detail , error: ' + data['errorDetail']);
                            PWM_MAIN.showError(data['errorDetail']);
                            PWM_MAIN.closeWaitDialog();
                            return;
                        }
                        var htmlBody = PWM_PS.convertDataResultToHtml(data['data']);
                        PWM_MAIN.showDialog({
                            title:data['data']['displayName'],
                            width:550,
                            allowMove:true,
                            text:htmlBody,
                            showClose:true,
                            loadFunction:function(){
                                var photoURL = PWM_MAIN.addPwmFormIDtoURL(data['data']['photoURL']);
                                if (photoURL) {
                                    PWM_PS.loadPicture(PWM_MAIN.getObject("userPhotoParentDiv"),photoURL);
                                }
                            }
                        });
                    }
                });
            });
        }
    });
};

PWM_PS.makeSearchGrid = function(nextFunction) {
    require(["dojo/domReady!"],function(){
        require(["dojo","dojo/_base/declare", "dgrid/Grid", "dgrid/Keyboard", "dgrid/Selection", "dgrid/extensions/ColumnResizer", "dgrid/extensions/ColumnReorder", "dgrid/extensions/ColumnHider", "dojo/domReady!"],
            function(dojo,declare, Grid, Keyboard, Selection, ColumnResizer, ColumnReorder, ColumnHider){

                var CustomGrid = declare([ Grid, Keyboard, Selection, ColumnResizer, ColumnReorder, ColumnHider ]);

                PWM_VAR['peoplesearch_search_grid'] = new CustomGrid({
                    columns: PWM_VAR['peoplesearch_search_columns']
                }, "grid");

                if (nextFunction) {
                    nextFunction();
                }
            });
    });
};

PWM_PS.initPeopleSearchPage = function() {
    PWM_PS.makeSearchGrid(function(){
        require(["dojo/dom-construct", "dojo/on"], function(domConstruct, on){
            on(PWM_MAIN.getObject('username'), "keyup, input", function(){
                PWM_PS.processPeopleSearch();
            });
            PWM_PS.processPeopleSearch();
        });
    });
};

PWM_PS.loadPicture = function(parentDiv,url) {
    require(["dojo/on"], function(on){
        var image = new Image();
        image.id="userPhotoImage";
        image.style = PWM_VAR['photo_style_attribute'];
        on(image,"load",function(){
            while (parentDiv.firstChild) {
                parentDiv.removeChild(parentDiv.firstChild);
            }
            parentDiv.appendChild(image);
        });
        image.src = url;
    });
};
