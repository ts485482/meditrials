package meditrials.meditrials.member.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.member.vo.MemberVO;

@Mapper
public interface MemberDAO {

    int countMembers();

    int countByEmail(@Param("email") String email);

    MemberVO selectMemberByNo(@Param("memberNo") Long memberNo);

    MemberVO selectMemberByEmail(@Param("email") String email);

    MemberVO selectLatestMember();

    int insertMember(MemberVO member);
}
