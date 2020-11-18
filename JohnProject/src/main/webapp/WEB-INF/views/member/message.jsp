<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<c:set var="path" value="${pageContext.request.contextPath }"/>

<jsp:include page="/WEB-INF/views/common/header.jsp">
	<jsp:param name="title" value=""/>
</jsp:include>
<section id="content">
		
</section>
<script>
	const memberSocket=new WebSocket("wss://localhost${path}/memberSocket");
	memberSocket.onopen=function(){
		console.log("memberSocket.onopen");
		console.log("myUsid: "+"${loginMember.usid}"+" otherUsid: "+"${otherInfo.otherUsid}");
	}
</script>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>









