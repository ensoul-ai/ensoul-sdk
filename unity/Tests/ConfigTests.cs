using System;
using System.Collections.Generic;
using NUnit.Framework;

namespace Ensoul.Tests
{
    [TestFixture]
    public class ConfigTests
    {
        [Test]
        public void DefaultConfig_HasCorrectDefaults()
        {
            var config = new EnsoulConfig();
            Assert.That(config.BaseUrl, Is.EqualTo("https://api.ensoul-ai.com"));
            Assert.That(config.Timeout, Is.EqualTo(TimeSpan.FromSeconds(30)));
            Assert.That(config.MaxRetries, Is.EqualTo(2));
            Assert.That(config.ApiKey, Is.Null);
            Assert.That(config.BearerToken, Is.Null);
        }

        [Test]
        public void CustomConfig_StoresAllValues()
        {
            var config = new EnsoulConfig(
                baseUrl: "https://staging.ensoul.ai",
                apiKey: "key-123",
                bearerToken: "token-abc",
                timeout: TimeSpan.FromSeconds(60),
                maxRetries: 5,
                customHeaders: new Dictionary<string, string> { ["X-Custom"] = "value" });

            Assert.That(config.BaseUrl, Is.EqualTo("https://staging.ensoul.ai"));
            Assert.That(config.ApiKey, Is.EqualTo("key-123"));
            Assert.That(config.BearerToken, Is.EqualTo("token-abc"));
            Assert.That(config.Timeout, Is.EqualTo(TimeSpan.FromSeconds(60)));
            Assert.That(config.MaxRetries, Is.EqualTo(5));
            Assert.That(config.CustomHeaders["X-Custom"], Is.EqualTo("value"));
        }

        [Test]
        public void ApiUrl_AppendsVersion()
        {
            var config = new EnsoulConfig(baseUrl: "https://api.ensoul-ai.com");
            Assert.That(config.ApiUrl, Is.EqualTo("https://api.ensoul-ai.com/v1"));
        }

        [Test]
        public void ApiUrl_StripsTrailingSlash()
        {
            var config = new EnsoulConfig(baseUrl: "https://api.ensoul-ai.com/");
            Assert.That(config.ApiUrl, Is.EqualTo("https://api.ensoul-ai.com/v1"));
        }

        [Test]
        public void CustomHeaders_DefaultsToEmpty()
        {
            var config = new EnsoulConfig();
            Assert.That(config.CustomHeaders, Is.Not.Null);
            Assert.That(config.CustomHeaders, Is.Empty);
        }
    }
}
