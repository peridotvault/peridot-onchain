import Blob "mo:base/Blob";
import Text "mo:base/Text";
import IC "ic:aaaaa-aa";

persistent actor PeridotAI {

  public shared query func HiPeridotAI() : async Text {
    return "Hi PeridotVault";
  };

  public query func transform({
    context : Blob;
    response : IC.http_request_result;
  }) : async IC.http_request_result {
    {
      response with headers = []; // not interested in the headers
    };
  };

  public shared func chat(prompt : Text) : async Text {
    let url : Text = "https://chatbot.peridotvault.com/chat";
    let request_headers = [{ name = "Content-Type"; value = "application/json" }];

    let request_body_json : Text = "{ \"query\": \"" # prompt # "\" }";
    let request_body = Text.encodeUtf8(request_body_json);

    let http_request : IC.http_request_args = {
      url = url;
      max_response_bytes = null; //optional for request
      headers = request_headers;
      body = ?request_body;
      method = #post;
      transform = ?{
        function = transform;
        context = Blob.fromArray([]);
      };
      is_replicated = ?false;
    };

    let http_response : IC.http_request_result = await (with cycles = 230_949_972_000) IC.http_request(http_request);

    let decoded_text : Text = switch (Text.decodeUtf8(http_response.body)) {
      case (null) { "No value returned" };
      case (?y) { y };
    };

    let result : Text = decoded_text # ". See more info of the request sent at: " # url # "/inspect";
    result;
  }

};
