package meditrials.meditrials.disease.api;

public class HiraDiseaseApiException extends RuntimeException {

    private static final long serialVersionUID = 1L;

    public HiraDiseaseApiException(String message) {
        super(message);
    }

    public HiraDiseaseApiException(String message, Throwable cause) {
        super(message, cause);
    }
}
