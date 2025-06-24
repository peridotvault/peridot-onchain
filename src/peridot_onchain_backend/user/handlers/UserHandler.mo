import Result "mo:base/Result";
import Char "mo:base/Char";
import UserType "../types/UserTypes";
import Core "./../../core/Core";

module {
    public class UserHandler() {

        type ApiResponse<T> = Core.ApiResponse<T>;

        public func validateUsername(username : Text) : Result.Result<(), Text> {
            let len = username.size();

            // Check length (3-30 characters)
            if (len < 3) {
                return #err("Username must be at least 3 characters long");
            };

            if (len > 30) {
                return #err("Username cannot exceed 30 characters");
            };

            // Check each character
            for (char in username.chars()) {
                if (not isValidUsernameChar(char)) {
                    return #err("Username can only contain lowercase letters, numbers, underscore (_) and hyphen (.)");
                };
            };

            #ok(());
        };

        private func isValidUsernameChar(char : Char) : Bool {
            // Check if character is:
            // - lowercase letter (a-z)
            // - number (0-9)
            // - underscore (_)
            // - hyphen (-)
            switch (char) {
                case ('.') { true };
                case ('_') { true };
                case (c) {
                    if (Char.isDigit(c)) { return true };
                    if (Char.isLowercase(c)) { return true };
                    false;
                };
            };
        };

        public func validateUser(user : UserType.User) : ApiResponse<()> {
            // Validate username
            switch (validateUsername(user.username)) {
                case (#err(msg)) {
                    return #err(#InvalidInput(msg));
                };
                case (#ok()) {};
            };

            // Validate display name length if provided
            switch (user.display_name) {
                case (name) {
                    if (name.size() > 50) {
                        return #err(#InvalidInput("Display name cannot exceed 50 characters"));
                    };
                };
            };

            #ok(());
        };
    };

};
