package com.kh.john.board.controller;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttributes;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import com.fasterxml.jackson.core.JsonGenerationException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.google.gson.JsonObject;
import com.kh.john.board.model.service.BoardService;
import com.kh.john.board.model.vo.Board;
import com.kh.john.board.model.vo.BoardFile;
import com.kh.john.board.model.vo.Comment;
import com.kh.john.board.model.vo.Subscribe;
import com.kh.john.member.model.vo.Member;

import lombok.extern.slf4j.Slf4j;

@Slf4j
//크로스 오리진 나중에 삭제해보기
@CrossOrigin(origins = "http://localhost:3000")
@Controller
@SessionAttributes("loginMember")
public class BoardController {
	
	@Autowired
	private BoardService service;
	
	
	@RequestMapping("/board/boardList")
	public ModelAndView boardList(ModelAndView mv, HttpServletRequest request) {
		//list페이지에서 subList 보내줘야함
		
		Member m = (Member) request.getSession().getAttribute("loginMember");
		
		List<Subscribe> list = service.boardSubList(m.getUsid());
		
		mv.addObject("subList", list);
		
		mv.setViewName("board/boardList");
		return mv;
	}
	
	@RequestMapping("/board/boardInsert")
	public ModelAndView boardInsert(ModelAndView mv) {
		
		mv.setViewName("/board/boardInsert");
		
		return mv;
	}
	
	@RequestMapping(value="/board/boardInsertEnd")
	public ModelAndView boardInsertEnd(MultipartFile[] upFiles, Board b, ModelAndView mv, HttpServletRequest request) {
		String saveDir = request.getServletContext().getRealPath("resources/upload_images/board");
		File dir = new File(saveDir);
		if(!dir.exists()) {
			dir.mkdirs();
		}
		
		List<BoardFile> files = new ArrayList();
		for(MultipartFile f : upFiles) {
			if(!f.isEmpty()) {
				String originalFilename = f.getOriginalFilename();
				String ext = originalFilename.substring(originalFilename.lastIndexOf('.')+1);
				
				SimpleDateFormat sdf = new SimpleDateFormat("yyyy_MM_ddHHmmssSSS");
				int rndNum = (int)(Math.random()*1000);
				String renamedFilename = sdf.format(new Date(System.currentTimeMillis())) + "_" + rndNum + "_john." + ext;
				try {
					f.transferTo(new File(saveDir + "/" + renamedFilename));
				}catch(IOException e) {
					e.printStackTrace();
				}
				BoardFile boardFile = new BoardFile();
				boardFile.setBoardFileName(renamedFilename);
				files.add(boardFile);
			}
		}
		int result = service.boardInsert(files, b);
		
		if(result>0) {
			mv.setViewName("/board/boardInsertSuccess");
		}else {
			mv.addObject("msg", "글 등록에 실패했습니다");
			mv.addObject("loc", "/board/boardList");
		}
		
		return mv;
	}

	@RequestMapping("board/boardPage")
	public ModelAndView boardPage(ModelAndView mv, int boardNo, HttpServletResponse response) {
		
		response.setHeader("Access-Control-Allow-Origin", "*");
		Board b = service.boardSelectOne(boardNo);
		
		mv.addObject("currBoard", b);
		mv.setViewName("/board/boardPage");
		
		return mv;
	}
	
	@ResponseBody
	@RequestMapping("board/boardCommentList")
	public List<Comment> boardCommentList(int currBoardNo)
			throws JsonMappingException, JsonGenerationException, IOException{
		
		List<Comment> list = service.commentSelectList(currBoardNo);
		
		return list;
	}
	
	@ResponseBody
	@RequestMapping("board/boardCommentInsert")
	public Map boardCommentInsert(@RequestParam Map param) throws JsonMappingException, JsonGenerationException, IOException {
		
		Map<String,String> result = new HashMap();
		
		int intResult = service.boardCommentInsert(param);
		
		if(intResult > 0) {
			result.put("result","success");
		}else {
			result.put("result","fail");
		}
		return result;
	}
	
	//작은 카테고리 조회
	@RequestMapping("/board/boardListSmall")
	public ModelAndView boardListSmall(String boardTitle, ModelAndView mv) {
		
		log.debug(boardTitle);
		
		List<Board> list = service.boardSelectCate(boardTitle);
		
		mv.addObject("list", list);
		mv.setViewName("/board/boardListSmall");
		
		return mv;
	}
	
	@RequestMapping(value="/board/boardFileUpload", method=RequestMethod.POST)
	@ResponseBody
	public String fileUpload(HttpServletRequest req, HttpServletResponse resp, 
                 MultipartHttpServletRequest multiFile) throws Exception {
		JsonObject json = new JsonObject();
		PrintWriter printWriter = null;
		OutputStream out = null;
		MultipartFile file = multiFile.getFile("upload");
		if(file != null){
			if(file.getSize() > 0 && StringUtils.isNotBlank(file.getName())){
				if(file.getContentType().toLowerCase().startsWith("image/")){
					try{
						String fileName = file.getName();
						byte[] bytes = file.getBytes();
						String uploadPath = req.getServletContext().getRealPath("/resources/upload_images");
						File uploadFile = new File(uploadPath);
						if(!uploadFile.exists()){
							uploadFile.mkdirs();
						}
						fileName = UUID.randomUUID().toString();
						uploadPath = uploadPath + "/" + fileName;
						out = new FileOutputStream(new File(uploadPath));
                        out.write(bytes);
                        
                        printWriter = resp.getWriter();
                        resp.setContentType("text/html");
                        String fileUrl = req.getContextPath() + "/resources/upload_images/" + fileName;
                        
                        // json 데이터로 등록
                        // {"uploaded" : 1, "fileName" : "test.jpg", "url" : "/img/test.jpg"}
                        // 이런 형태로 리턴이 나가야함.
                        json.addProperty("uploaded", 1);
                        json.addProperty("fileName", fileName);
                        json.addProperty("url", fileUrl);
                        
                        printWriter.println(json);
                    }catch(IOException e){
                        e.printStackTrace();
                    }finally{
                        if(out != null){
                            out.close();
                        }
                        if(printWriter != null){
                            printWriter.close();
                        }		
					}
				}
			}
		}
		return null;
	}	
}
