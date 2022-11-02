import ballerinax/github;
import ballerina/http;
import ballerina/io;

configurable string token = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get stars/[string org]/[int count]() returns string[]?|error {
        // Send a response back to the caller.
        github:Client githubEp = check new (config = {
            auth: {
                token: token
            }
        });

        stream<github:Repository, github:Error?> repositories = check githubEp->getRepositories("wso2", true);
        //io:println("Repos: " + repositories.toString());

        string[]? repoArray = check from github:Repository repo in repositories
            order by repo.stargazerCount
            limit count
            select repo.name;

        foreach var s in repoArray ?: [] {
            io:println(s);
        }

        return repoArray;

    }
}
