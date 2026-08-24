package meditrials.meditrials.business.dao;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import meditrials.meditrials.business.vo.BusinessVO;

@Mapper
public interface BusinessDAO {

    int countBusinesses();

    int countMemberBusinessLinks();

    int countByBusinessRegNo(@Param("businessRegNo") String businessRegNo);

    BusinessVO selectBusinessByNo(@Param("businessNo") Long businessNo);

    BusinessVO selectBusinessByMemberNo(@Param("memberNo") Long memberNo);

    BusinessVO selectLatestBusiness();

    int insertBusiness(BusinessVO business);

    int updateBusinessProfile(
            @Param("memberNo") Long memberNo,
            @Param("phone") String phone,
            @Param("email") String email,
            @Param("address") String address,
            @Param("description") String description);
}
