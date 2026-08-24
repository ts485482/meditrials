package meditrials.meditrials.trial.api;

public class CrisClinicalTrialException extends RuntimeException {

    public CrisClinicalTrialException(String message) {
        super(message);
    }

    public CrisClinicalTrialException(String message, Throwable cause) {
        super(message, cause);
    }
}
