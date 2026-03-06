using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class ErrorTests
    {
        // Helper: call the HttpStatusCode overload
        private static void Throw(HttpStatusCode status, string body)
            => ErrorHandler.ThrowForStatus(status, body);

        [Test]
        public void ThrowForStatus_200_DoesNotThrow()
        {
            Assert.DoesNotThrow(() => Throw(HttpStatusCode.OK, "{}"));
        }

        [Test]
        public void ThrowForStatus_401_ThrowsAuthenticationException()
        {
            var ex = Assert.Throws<AuthenticationException>(
                () => Throw(HttpStatusCode.Unauthorized, Fixtures.Error401Json));
            Assert.That(ex.StatusCode, Is.EqualTo(401));
            Assert.That(ex.Message, Is.EqualTo("Token missing"));
        }

        [Test]
        public void ThrowForStatus_403_ThrowsAuthorizationException()
        {
            var ex = Assert.Throws<AuthorizationException>(
                () => Throw(HttpStatusCode.Forbidden, Fixtures.Error403Json));
            Assert.That(ex.StatusCode, Is.EqualTo(403));
            Assert.That(ex.Message, Is.EqualTo("Insufficient permissions"));
        }

        [Test]
        public void ThrowForStatus_404_ThrowsNotFoundException()
        {
            var ex = Assert.Throws<NotFoundException>(
                () => Throw(HttpStatusCode.NotFound, Fixtures.Error404Json));
            Assert.That(ex.StatusCode, Is.EqualTo(404));
            Assert.That(ex.Message, Is.EqualTo("Persona not found"));
        }

        [Test]
        public void ThrowForStatus_409_ThrowsConflictException()
        {
            var ex = Assert.Throws<ConflictException>(
                () => Throw(HttpStatusCode.Conflict, @"{""error"": ""Conflict"", ""message"": ""Already exists""}"));
            Assert.That(ex.StatusCode, Is.EqualTo(409));
            Assert.That(ex.Message, Is.EqualTo("Already exists"));
        }

        [Test]
        public void ThrowForStatus_422_ThrowsValidationException_WithDetails()
        {
            var ex = Assert.Throws<ValidationException>(
                () => Throw(HttpStatusCode.UnprocessableEntity, Fixtures.Error422Json));
            Assert.That(ex.StatusCode, Is.EqualTo(422));
            Assert.That(ex.Details, Has.Count.EqualTo(1));
            Assert.That(ex.Details[0].Field, Is.EqualTo("name"));
            Assert.That(ex.Details[0].Type, Is.EqualTo("missing"));
        }

        [Test]
        public void ThrowForStatus_429_ThrowsRateLimitException_WithRetryAfter()
        {
            // Use the int overload which reads headers dict
            var headers = new Dictionary<string, System.Collections.Generic.IEnumerable<string>>
            {
                ["Retry-After"] = new[] { "60" }
            };
            var ex = Assert.Throws<RateLimitException>(
                () => ErrorHandler.ThrowForStatus(429, Fixtures.Error429Json, headers));
            Assert.That(ex.StatusCode, Is.EqualTo(429));
            Assert.That(ex.RetryAfter, Is.EqualTo(60.0));
        }

        [Test]
        public void ThrowForStatus_500_ThrowsServerException()
        {
            var ex = Assert.Throws<ServerException>(
                () => Throw(HttpStatusCode.InternalServerError, Fixtures.Error500Json));
            Assert.That(ex.StatusCode, Is.EqualTo(500));
            Assert.That(ex.Message, Is.EqualTo("Unexpected failure"));
        }

        [Test]
        public void ThrowForStatus_503_ThrowsServerException()
        {
            var ex = Assert.Throws<ServerException>(
                () => Throw(HttpStatusCode.ServiceUnavailable, @"{""error"": ""Unavailable"", ""message"": ""Service down""}"));
            Assert.That(ex.StatusCode, Is.EqualTo(503));
        }

        [Test]
        public void ThrowForStatus_UnknownStatus_ThrowsApiException()
        {
            var ex = Assert.Throws<ApiException>(
                () => Throw((HttpStatusCode)418, @"{""error"": ""Teapot"", ""message"": ""I am a teapot""}"));
            Assert.That(ex.StatusCode, Is.EqualTo(418));
            Assert.That(ex, Is.Not.TypeOf<AuthenticationException>());
        }

        [Test]
        public void ThrowForStatus_InvalidJson_UsesUnknownError()
        {
            var ex = Assert.Throws<ServerException>(
                () => Throw(HttpStatusCode.InternalServerError, "not valid json!!"));
            Assert.That(ex.StatusCode, Is.EqualTo(500));
            Assert.That(ex.Error, Is.EqualTo("Unknown Error"));
        }

        [Test]
        public void ThrowForStatus_EmptyBody_UsesUnknownError()
        {
            var ex = Assert.Throws<ServerException>(
                () => Throw(HttpStatusCode.InternalServerError, ""));
            Assert.That(ex.StatusCode, Is.EqualTo(500));
            Assert.That(ex.Error, Is.EqualTo("Unknown Error"));
        }

        [Test]
        public void AuthenticationException_IsApiException()
        {
            var ex = new AuthenticationException(401, "Unauthorized", "Token missing");
            Assert.That(ex, Is.InstanceOf<ApiException>());
        }

        [Test]
        public void ApiException_IsEnsoulException()
        {
            var ex = new ApiException(500, "Error", "message");
            Assert.That(ex, Is.InstanceOf<EnsoulException>());
        }

        [Test]
        public void ValidationException_EmptyDetails_DefaultsToEmptyList()
        {
            var ex = new ValidationException(422, "Validation Error", "Invalid");
            Assert.That(ex.Details, Is.Not.Null);
            Assert.That(ex.Details, Is.Empty);
        }

        [Test]
        public void ErrorDetail_StoresFieldMessageType()
        {
            var detail = new ErrorDetail("email", "Invalid format", "format");
            Assert.That(detail.Field, Is.EqualTo("email"));
            Assert.That(detail.Message, Is.EqualTo("Invalid format"));
            Assert.That(detail.Type, Is.EqualTo("format"));
        }

        [Test]
        public void ApiException_StoresStatusCodeErrorMessageRequestId()
        {
            var ex = new ApiException(404, "Not Found", "Resource missing", "req-123");
            Assert.That(ex.StatusCode, Is.EqualTo(404));
            Assert.That(ex.Error, Is.EqualTo("Not Found"));
            Assert.That(ex.Message, Is.EqualTo("Resource missing"));
            Assert.That(ex.RequestId, Is.EqualTo("req-123"));
        }

        [Test]
        public void RateLimitException_DefaultRetryAfterIsZero()
        {
            var ex = new RateLimitException(429, "Rate Limited", "Too many requests");
            Assert.That(ex.RetryAfter, Is.EqualTo(0.0));
        }

        [Test]
        public void AuthorizationException_StoresRequiredAndCurrentTier()
        {
            var ex = new AuthorizationException(403, "Forbidden", "Need higher tier",
                requiredTier: "pro", currentTier: "free");
            Assert.That(ex.RequiredTier, Is.EqualTo("pro"));
            Assert.That(ex.CurrentTier, Is.EqualTo("free"));
        }

        [Test]
        public void NotFoundException_StoresResourceTypeAndId()
        {
            var ex = new NotFoundException(404, "Not Found", "Persona not found",
                resourceType: "persona", resourceId: "p-abc");
            Assert.That(ex.ResourceType, Is.EqualTo("persona"));
            Assert.That(ex.ResourceId, Is.EqualTo("p-abc"));
        }
    }
}
