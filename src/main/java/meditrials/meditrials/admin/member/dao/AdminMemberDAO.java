package meditrials.meditrials.admin.member.dao;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.admin.member.vo.AdminMemberVO;

@Mapper
public interface AdminMemberDAO {

    List<AdminMemberVO> selectMembers(@Param("keyword") String keyword);

    AdminMemberVO selectMemberByNo(@Param("memberNo") Long memberNo);

    int countByStatus(@Param("status") String status);

    int updateMemberStatus(
            @Param("memberNo") Long memberNo,
            @Param("status") String status);
}
