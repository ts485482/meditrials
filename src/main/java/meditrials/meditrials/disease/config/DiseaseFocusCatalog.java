package meditrials.meditrials.disease.config;

import java.util.List;
import java.util.Locale;

public final class DiseaseFocusCatalog {

    private static final List<FocusDisease> FOCUS_DISEASES = List.of(
            new FocusDisease(
                    "알츠하이머병",
                    "Alzheimer Disease",
                    "신경퇴행성 질환",
                    List.of("알츠하이머병", "알츠하이머"),
                    List.of("G30"),
                    "Alzheimer Disease"),
            new FocusDisease(
                    "파킨슨병",
                    "Parkinson Disease",
                    "신경퇴행성 질환",
                    List.of("파킨슨병", "파킨슨"),
                    List.of("G20"),
                    "Parkinson Disease"),
            new FocusDisease(
                    "근위축성 측삭경화증 (ALS)",
                    "Amyotrophic Lateral Sclerosis",
                    "신경퇴행성 질환",
                    List.of("근위축성 측삭경화증", "근위축성측삭경화증", "운동신경원병"),
                    List.of("G12"),
                    "Amyotrophic Lateral Sclerosis"),
            new FocusDisease(
                    "헌팅턴병",
                    "Huntington Disease",
                    "유전성 질환",
                    List.of("헌팅턴병", "헌팅톤병"),
                    List.of("G10"),
                    "Huntington Disease"),
            new FocusDisease(
                    "다발성 경화증",
                    "Multiple Sclerosis",
                    "자가면역·면역 질환",
                    List.of("다발성 경화증", "다발경화증"),
                    List.of("G35"),
                    "Multiple Sclerosis"),
            new FocusDisease(
                    "전신홍반루푸스",
                    "Systemic Lupus Erythematosus",
                    "자가면역·면역 질환",
                    List.of("전신홍반루푸스", "전신성홍반루푸스", "전신홍반성루푸스"),
                    List.of("M32"),
                    "Systemic Lupus Erythematosus"),
            new FocusDisease(
                    "크론병",
                    "Crohn Disease",
                    "자가면역·면역 질환",
                    List.of("크론병", "크론"),
                    List.of("K50"),
                    "Crohn Disease"),
            new FocusDisease(
                    "특발성 폐섬유증",
                    "Idiopathic Pulmonary Fibrosis",
                    "만성·난치성 질환",
                    List.of("특발성 폐섬유증", "특발성폐섬유증", "폐섬유증"),
                    List.of("J84"),
                    "Idiopathic Pulmonary Fibrosis"),
            new FocusDisease(
                    "췌장암",
                    "Pancreatic Cancer",
                    "암·종양성 질환",
                    List.of("췌장암", "췌장의 악성 신생물"),
                    List.of("C25"),
                    "Pancreatic Cancer"),
            new FocusDisease(
                    "교모세포종",
                    "Glioblastoma",
                    "암·종양성 질환",
                    List.of("교모세포종", "아교모세포종", "뇌의 악성 신생물"),
                    List.of("C71"),
                    "Glioblastoma"),
            new FocusDisease(
                    "뒤센근이영양증",
                    "Duchenne Muscular Dystrophy",
                    "유전성 질환",
                    List.of("뒤센근이영양증", "뒤쉔근이영양증", "근이영양증"),
                    List.of("G71"),
                    "Duchenne Muscular Dystrophy"),
            new FocusDisease(
                    "낭포성 섬유증",
                    "Cystic Fibrosis",
                    "유전성 질환",
                    List.of("낭포성 섬유증", "낭성 섬유증", "낭성섬유증"),
                    List.of("E84"),
                    "Cystic Fibrosis")
    );

    private DiseaseFocusCatalog() {
    }

    public static List<FocusDisease> diseases() {
        return FOCUS_DISEASES;
    }

    public static FocusDisease findBestMatch(String koreanName, String englishName) {
        String normalizedKoreanName = normalize(koreanName);
        String normalizedEnglishName = normalize(englishName);

        for (FocusDisease focus : FOCUS_DISEASES) {
            if (matchesKoreanName(focus, normalizedKoreanName)
                    || matchesEnglishName(focus, normalizedEnglishName)) {
                return focus;
            }
        }
        return null;
    }

    private static boolean matchesKoreanName(
            FocusDisease focus,
            String normalizedKoreanName) {
        if (normalizedKoreanName.isEmpty()) {
            return false;
        }

        if (nameMatches(normalizedKoreanName, normalize(focus.koreanName()))) {
            return true;
        }

        for (String searchTerm : focus.hiraSearchTerms()) {
            if (nameMatches(normalizedKoreanName, normalize(searchTerm))) {
                return true;
            }
        }
        return false;
    }

    private static boolean matchesEnglishName(
            FocusDisease focus,
            String normalizedEnglishName) {
        if (normalizedEnglishName.isEmpty()) {
            return false;
        }
        return nameMatches(normalizedEnglishName, normalize(focus.englishName()))
                || nameMatches(normalizedEnglishName, normalize(focus.clinicalTrialsQuery()));
    }

    private static boolean nameMatches(String left, String right) {
        return !left.isEmpty()
                && !right.isEmpty()
                && (left.equals(right) || left.contains(right) || right.contains(left));
    }

    private static String normalize(String value) {
        if (value == null) {
            return "";
        }
        return value.replace(" ", "")
                .replace("-", "")
                .replace("'", "")
                .replace("’", "")
                .replace("(", "")
                .replace(")", "")
                .toLowerCase(Locale.ROOT)
                .trim();
    }

    public record FocusDisease(
            String koreanName,
            String englishName,
            String category,
            List<String> hiraSearchTerms,
            List<String> expectedKcdPrefixes,
            String clinicalTrialsQuery) {
    }
}
