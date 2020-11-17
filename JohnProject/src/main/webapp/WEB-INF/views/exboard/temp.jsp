<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="path" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>영상 상담 임시 테스트용</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<!-- jQuery library -->
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<!-- Popper JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<!-- Latest compiled JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/lodash.js/0.10.0/lodash.min.js"></script>
</head>
<style>
.container {
	border: 1px solid black;
	border-radius: 8px;
	margin: 50px auto;
	max-width: 80%;
	text-align: center;
	padding: 2%;
}

#video2 {
	width: 60%;
	height: 70%;
	float: center;
}

#video1 {
	width: 30%;
	height: 40%;
	float: center;
}

#text {
	margin-top: 2em;
	width: 100%;
	height: 200px;
	color: white;
	text-align: center;
	font-size: 20px;
}

/* #board {
	border: 1px solid gray;
	background-color: rgb(200, 200, 200);
	width: 100%;
	height: 500px;
	overflow-x: hidden;
	-ms-overflow-style: none;
} */

#board>div {
	font-size: 20px;
	color: yellow;
	font-weight: bold;
}
/* 스크롤 바 투명하게 만들기 */
::-webkit-scrollbar {
	display: none;
}

#textboard {
	display: inline-block;
}

#previewImg img{
width:50px;
height:50px;
display:flex;
}

#expertTextDiv{
	width:460px;
	height:400px;
	border:1px solid black;
			overflow-x: hidden;
	-ms-overflow-style: none;	
}

.upload{
	width:100px;
	height:100px;
}


</style>

<body>
	<section>
		<section class="container">
			<!-- <h3>Another</h3> -->
			<video id="video2" autoplay playsinline controls preload="metadata"></video>
			<!-- <h3>ME</h3> -->
			<video id="video1" autoplay playsinline controls preload="metadata"></video>
			<br> <br>

			<!-- 	<button type="button" class="btn btn-outline-success my-2 my-sm-0" onclick='connection();'>연결</button>
			<button type="button" class="btn btn-outline-success my-2 my-sm-0" onclick='exit();'>연결 끊기</button> -->

			<div id="textboard">
				<c:if test="${loginMember.memClass == '전문가'}">
					<div id="expertTextDiv"></div>
					<br>
					<textarea id="extext" rows="2" cols="60"></textarea>
					<br>
						<div id="previewImg"></div>
					<button type="button" class="btn btn-outline-success my-2 my-sm-0" onclick='counselEnd();'>상담 완료</button>
					<input type="button" class="btn btn-outline-success my-2 my-sm-0" id="btnSubmit" value="업로드" />
				</c:if>

				<c:if test="${loginMember.memClass != '전문가'}">
					<div id="expertTextDiv"></div>
					<br>
						<div id="previewImg"></div>
					<button type="button" class="btn btn-outline-success my-2 my-sm-0" onclick='onoff();'>카메라 조정</button>
					<input type="button" class="btn btn-outline-success my-2 my-sm-0" id="btnSubmit" value="업로드" />
				</c:if>
			
			</div>


		</section>

		<script>
			'use strict';
			
			function imgView(e){
				console.log("눌림림 : "+$(e.target).attr( 'title' ));
				window.open('${path}/resources/upload_images/'+$(e.target).attr( 'title' ),'이미지','width=800, height=700, toolbar=no, menubar=no, scrollbars=no, resizable=yes');
			};
			
			//---------------------------- 드래그 파일 -------------------------------------

			let uploadFiles = [];
 			let $drop = $("#expertTextDiv");

			$drop.on("dragenter", function(e) { 
				console.log("드래그 들어왔을떄");
				$(this).addClass('drag-over');
			}).on("dragleave", function(e) { 
				console.log("드래그 나갔을때");
				$(this).removeClass('drag-over');
			}).on("dragover", function(e) {
				e.stopPropagation();
				e.preventDefault();
			}).on('drop', function(e) { 
				console.log("드래그 항목을 떨어뜨렸을때");
				e.preventDefault();
				$(this).removeClass('drag-over');
				let files = e.originalEvent.dataTransfer.files;
				//console.log("files : " + files);
				for (let i = 0; i < files.length; i++) {
					let file = files[i];
					let size = uploadFiles.push(file); //업로드 목록에 추가
					preview(file, size - 1); //미리보기 만들기
				}

			});
			
			//---------------------------- 드래그 파일 미리보기 -------------------------------------

			function preview(file, idx) {
				let reader = new FileReader();
				reader.onload = (function(f, idx) {
					return function(e) {
						let div = '<div class="thumb"> \ <div class="close" data-idx="' + idx + '">X</div> \ <img src="' + e.target.result + '" title="' + escape(f.name) + '"/> \ </div>';
						$("#previewImg").append(div);
					};
				})(file, idx);
				reader.readAsDataURL(file);
			}

			//---------------------------- 드래그 파일 전송 -------------------------------------
			
			$("#btnSubmit").on("click", function() {
				let formData = new FormData();
				$.each(uploadFiles, function(i, file) {
					if (file.upload != 'disable') //삭제하지 않은 이미지만 업로드 항목으로 추가
						formData.append('upFile', file, file.name);
				});

				$.ajax({
					url : '${path}/expert/upload',
					data : formData,
					type : 'post',
					contentType : false,
					processData : false,
					dataType : "json",
					success : function(data) {
						console.log("파일 업로드 완료 data : " + data);
						let msg = "";
						$.each(data, function(i, item) {
							console.log("i : " + i + ", item : " + item);
							msg += item + "|";
						});
						console.log(msg);
						sendMessage(new ExboardMsg("FILE", "", msg));
						$("#previewImg").html("");
						imgDivPrint(msg);
						//배열 초기화 안그러면 계속 들어감..
						uploadFiles = [];
					}
				});
			});

			$("#previewImg").on("click", ".close", function(e) {
				let $target = $(e.target);
				let idx = $target.attr('data-idx');
				uploadFiles[idx].upload = 'disable'; //삭제된 항목은 업로드하지 않기 위해 플래그 생성
				$target.parent().remove(); //프리뷰 삭제
			});

			//---------------------------- 상담 설정 -------------------------------------

			//마이크 비디오 설정
			const video1 = document.getElementById('video1');
			const video2 = document.getElementById('video2');
			let flag = true;
			let pc;
			let localStream;
			let remoteStream;
			let rtc_peer_connection = null;
			let rtc_session_description = null;
			let get_user_media = null;
			//let user_cam=null;
			let user_usid;

			/* 		let cam = _.once = function(func){
						console.log("once");
						return false;
					}; 
					user_cam = cam();
					console.log("user_cam : "+user_cam); */

			//TURN & STUN 서버 등록
			const configuration = {
				'iceServers' : [ {
					'urls' : 'stun:stun.l.google.com:19302'
				}, {
					'url' : 'turn:numb.viagenie.ca',
					'credential' : 'muazkh',
					'username' : 'webrtc@live.com'
				} ]
			};

			//---------------------------- signaling 서버 -------------------------------------

			//const conn = new WebSocket('wss://192.168.120.31${path}/ertc');
			const conn = new WebSocket('wss://192.168.219.105${path}/ertc');
			//const conn = new WebSocket('wss://localhost${path}/ertc');

			conn.onopen = function() {
				console.log("onopen => signaling server 연결");
				if ("${loginMember.memClass}" != '전문가') {
					sendMessage(new ExboardMsg("SYS",
							"${loginMember.memNickname}", "접속",
							"${loginMember.usid}"));
				}

			};

			conn.onmessage = function(msg) {
				console.log("onmessage => 메세지 출력 : " + msg);
				let content = JSON.parse(msg.data);
				console.log("content.type : " + content.type);
				if (content.type === 'expert') {
					console.log(" === 분기 expert === ");
					start();
				} else if (content.type === 'offer') {
					console.log(" === 분기 offer === ");
					start();
					pc
							.setRemoteDescription(new rtc_session_description(
									content));
					doAnswer();
				} else if (content.type === 'answer') {
					console.log(" === 분기 answer === ");
					pc
							.setRemoteDescription(new rtc_session_description(
									content));

				} else if (content.type === 'candidate') {
					console.log(" === 분기 candidate === ");
					let candidate = new RTCIceCandidate({
						sdpMLineIndex : content.label,
						candidate : content.candidate
					});
					pc.addIceCandidate(candidate);
				} else if (content.type == 'SYS') {
					console.log(" === 분기 SYS === ");
					start();
					user_usid = content.id;
					$("#expertTextDiv").html("<p>"+content.nick + "님이 접속하셨습니다.</p><br>");
				} else if (content.type == 'TXT') {
					console.log(" === 분기 TXT === ");
					
					$("#expertTextDiv").html($("#expertTextDiv").html()+"<p>"+content.msg+"</p>");
					$("#expertTextDiv").scrollTop($("#expertTextDiv")[0].scrollHeight);
				} else if (content.type == 'CAM') {
					console.log(" === 분기 CAM === ");
					if (content.msg === 'off') {
						video2.srcObject = null;
						$("#expertTextDiv").html($("#expertTextDiv").html() + "<br><p>유저가 카메라를 끄셨습니다.</p>");
						//user_cam = false;
					} else {
						video2.srcObject = remoteStream;
						$("#expertTextDiv").html($("#expertTextDiv").html() + "<br><p>유저가 카메라를 키셨습니다.</p>");
						//user_cam = true;
					}
				} else if (content.type == 'FILE') {
					console.log(" === 분기 FILE === ");
					console.log("content : " + content.msg);
					imgDivPrint(content.msg);
				} else if (content.type == 'END') {
					console.log(" === 분기 END === ");
					exit();
					location.replace('${path}/');
				}
			};

			conn.onclose = function() {
				console.log('onclose 실행');
			};

			function sendMessage(message) {
				conn.send(JSON.stringify(message));
				console.log("메세지 보내는 함수 sendMessage");
			};
			
			function imgDivPrint(msg){
				console.log("msg : "+msg);
				let list = msg.split('|');
				let imgprint = "";
				for(let i in list){
					console.log(list[i]);
					if(i == list.length-1){
						console.log("나감");
						break;
					}
					imgprint+="<img  class='upload' src='${path}/resources/upload_images/"+list[i]+"' title='"+list[i]+"' onclick='imgView(event);' style='cursor: pointer'/><br>";
				}
				let con = $("#expertTextDiv").html()+imgprint;
				$("#expertTextDiv").html("");
				$("#expertTextDiv").html(con);
				$("#expertTextDiv").scrollTop($("#expertTextDiv")[0].scrollHeight);
				list="";
				imgprint="";
				console.log("msg2 : "+msg);
			}

			//---------------------------- 비디오 설정 -------------------------------------

			const constraints = {
				video : {
					width : {
						exact : 1280
					},
					height : {
						exact : 720
					}
				},
				audio : true
			};
			if (navigator.getUserMedia) {
				console.log("getUserMedia");
				get_user_media = navigator.getUserMedia.bind(navigator);
				videoStart();
				rtc_peer_connection = RTCPeerConnection;
				rtc_session_description = RTCSessionDescription;
			} else if (navigator.mozGetUserMedia) {
				console.log("mozGetUserMedia");
				get_user_media = navigator.mozGetUserMedia.bind(navigator);
				videoStart();
				rtc_peer_connection = mozRTCPeerConnection;
				rtc_session_description = mozRTCSessionDescription;
			} else if (navigator.webkitGetUserMedia) {
				console.log("webkitGetUserMedia");
				get_user_media = navigator.webkitGetUserMedia.bind(navigator);
				videoStart();
				rtc_peer_connection = webkitRTCPeerConnection;
				rtc_session_description = webkitRTCSessionDescription;
			} else {
				console.log("지원안하는 브라우저");
				alert("지원하지 않는 브라우저입니다. firefox chrome브라우저를 이용하세요");
				flag = false;
			}

			function videoStart() {
				get_user_media(constraints, function(stream) {
					console.log('stream 함수 => 스트림 요청 성공');
					localStream = stream;
					console.log("localStream : " + localStream);
					if ("${loginMember.memClass}" == '전문가') {
						video1.srcObject = localStream;
					}
					sendMessage(new ExboardMsg("expert"));
					console.log("메세지 보냄!");
					console.log("gotStream 함수 => start 실행");
					start();
				}, function(e) {
					alert('카메라와 마이크를 허용해주세요 / 에러 : ' + e.name);
				});
			}

			//---------------------------- P2P 연결 로직 -------------------------------------

			function start() {
				if (flag && typeof localStream !== 'undefined') {
					console.log("peer 연결 부분 분기 진입");
					createPeerConnection();
					pc.addStream(localStream);
					flag = false;
					console.log("do call 실행됨 ");
					doCall();
				}
			};

			function createPeerConnection() {
				console.log("createPeerConnection 실행");
				try {
					//configuration에는 STUN & TURN 서버가 있음
					//STUN : Session Traversal Utilities for NAT의 약자로 자신의 공인 아이피를 알아오기위해 STUN 서버에 요청하고 STUN 서버는 공인 IP주소를 응답함.
					//TURN : Traversal Using Relays around NAT 의 약자 NAT 또는 방화벽에서 보조하는 프로토콜. 클라이언트는 직접 서버와 통신 하지않고 TURN 서버를 경유함.
					pc = new rtc_peer_connection(configuration);
					pc.onicecandidate = handleIceCandidate;
					pc.onaddstream = handleRemoteStreamAdded;
					pc.onremovestream = handleRemoteStreamRemoved;
					console.log(" RTCPeerConnection 생성 완료 ");
				} catch (e) {
					console.log(" RTCPeerConnection 생성 에러발생 : " + e.message);
					alert("RTCPeerConnection 에러");
					return;
				}
			};

			function handleRemoteStreamAdded(event) {
				console.log("RemoteStream 추가됨");
				//원격 스트림에 스트림을 넣어줌
				remoteStream = event.stream;
				if ("${loginMember.memClass}" != '전문가') {
					video2.srcObject = remoteStream;
				}
				/* else{
					if(user_cam != false){
						video2.srcObject = remoteStream;
					} 
				}
				 */
			};

			function doCall() {
				console.log("createOff 함수를 통해서 통신 요청");
				pc.createOffer(setLocalAndSendMessage, handleCreateOfferError);
			};

			function doAnswer() {
				console.log('peer에게 응답 보내기.');
				pc.createAnswer().then(setLocalAndSendMessage,
						onCreateSessionDescriptionError);
			};

			//핸들러 후보 상대방 탐색
			//ICE : Interactive Connectivity Establishment의 약자로 두 단말이 서로 통신할수 있는 최적의 경로를 찾을수있도록 도와주는 프레임워크임.
			function handleIceCandidate(event) {
				console.log('icecandidate 실행 event : ' + event);
				if (event.candidate) {
					console.log('icecandidate 응답 보내기 ');
					sendMessage({
						type : 'candidate',
						label : event.candidate.sdpMLineIndex,
						id : event.candidate.sdpMid,
						candidate : event.candidate.candidate
					});
				} else {
					console.log(' handleIceCandidate 탐색 종료 ');
				}
			};

			function handleRemoteStreamRemoved(event) {
				console.log('원격 스트림 삭제됨 Event : ' + event);
			};

			function setLocalAndSendMessage(sessionDescription) {
				pc.setLocalDescription(sessionDescription);
				console.log("setLocalAndSendMessage 응답 보내기 : "
						+ sessionDescription);
				sendMessage(sessionDescription);
			};

			//연결 끊기
			function exit() {
				stop();
				console.log('연결 종료 응답 보내기 ');
				sendMessage(new ExboardMsg("END"));
			};

			function stop() {
				console.log('연결 종료');
				pc.close();
				pc = null;
			};

			//---------------------------- 잡다한 메소드 -------------------------------------

			function handleCreateOfferError(event) {
				console.log('Offer부분 생성 에러 error: ', event);
			};

			function onCreateSessionDescriptionError(error) {
				trace('onCreateSessionDescriptionError 에러 : '
						+ error.toString());
			}

			//메세지 객체
			function ExboardMsg(type, nick, msg, id, sdp, label, candidate) {
				this.type = type;
				this.nick = nick;
				this.msg = msg;
				this.id = id;
				this.sdp = sdp;
				this.label = label;
				this.candidate = candidate;
			};

			//엔터키 입력시 메세지 발송
			$("#extext").keyup(function(key) {
				if (key.keyCode == 13) {
					let txt = $("#extext").val();
					$("#extext").val("");
					console.log(txt);
					sendMessage(new ExboardMsg("TXT", "", txt));
					$("#expertTextDiv").html($("#expertTextDiv").html()+"<p>"+txt+"</p>");
					$("#expertTextDiv").scrollTop($("#expertTextDiv")[0].scrollHeight);
				}
			});

			//상담 종료 해당 텍스트 에어리어의 기록 디비에 저장하고 종료
			function counselEnd() {
				console.log("user_usid : " + user_usid);
				let result = confirm("해당 회원과 상담을 종료 하시겠습니까?");
				if (result) {
					let form = document.createElement("form");
					form.setAttribute("charset", "UTF-8");
					form.setAttribute("method", "Post");
					form.setAttribute("action", "${path}/expert/counselEnd");
					let hiddenField = document.createElement("input");
					hiddenField.setAttribute("type", "hidden");
					hiddenField.setAttribute("name", "extext");
					hiddenField.setAttribute("value", $("#expertTextDiv").html());
					form.appendChild(hiddenField);
					let hiddenField2 = document.createElement("input");
					hiddenField2.setAttribute("type", "hidden");
					hiddenField2.setAttribute("name", "bno");
					hiddenField2.setAttribute("value", "${bno}");
					form.appendChild(hiddenField2);
					document.body.appendChild(form);
					form.submit();
					exit();
					sendMessage(new ExboardMsg("END",
							"${loginMember.memClass}", "종료"));
					//header가 없어서 알람을 못보냄 나중에 여기에 헤더를 넣을지 말지 상의해서 추가하기
					//sendAlarm("${loginMember.usid}",user_usid,"expertend",bno,"${loginMember.memNickname}");
				}
			}

			function onoff() {

				if (video1.srcObject != null) {
					//캠 켜있다.
					video1.srcObject = null;
					sendMessage(new ExboardMsg("CAM", "", "off"));
				} else {
					video1.srcObject = localStream;
					sendMessage(new ExboardMsg("CAM", "", "on"));
				}
			};
			
		
			
			
			
			
		</script>
</body>
</html>