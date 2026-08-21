// This file is compiled inside Decidim core pack. Code can be added here and will be executed
// as part of that pack
// Load images
require.context("../../images", true)

const CHATBOT_PROFILE_PATTERN = /(chatbot|whatsapp)/i
const COMMENT_AUTHOR_SELECTOR = ".comment .author__container"

const aliasFromSource = (source) => {
  const input = String(source || "anon")
  let hash = 0
  for (let i = 0; i < input.length; i += 1) {
    hash = (hash << 5) - hash + input.charCodeAt(i)
    hash |= 0
  }
  const number = (Math.abs(hash) % 9000) + 1000
  return `anonimo.${number}`
}

const isChatbotAuthorContainer = (container) => {
  const profilePath = container.getAttribute("href") || ""
  return CHATBOT_PROFILE_PATTERN.test(profilePath)
}

const anonymizeCommentAuthor = (container) => {
  if (!container || container.dataset.chatbotAliasApplied === "true") return
  if (!isChatbotAuthorContainer(container)) return

  const nameNode = container.querySelector(".author__name")
  if (!nameNode) return

  const source = container.getAttribute("href") || nameNode.textContent || Math.random().toString()
  const alias = aliasFromSource(source)

  nameNode.textContent = alias
  nameNode.setAttribute("title", alias)
  container.dataset.chatbotAliasApplied = "true"
}

const anonymizeChatbotCommentAuthors = (scope = document) => {
  const containers = scope.querySelectorAll(COMMENT_AUTHOR_SELECTOR)
  containers.forEach(anonymizeCommentAuthor)
}

const setupChatbotAuthorsAnonymizer = () => {
  if (window.__decidimChatbotAuthorsAnonymizerReady) {
    anonymizeChatbotCommentAuthors()
    return
  }

  window.__decidimChatbotAuthorsAnonymizerReady = true
  anonymizeChatbotCommentAuthors()

  const observer = new MutationObserver((mutations) => {
    mutations.forEach((mutation) => {
      mutation.addedNodes.forEach((node) => {
        if (!(node instanceof HTMLElement)) return

        if (typeof node.matches === "function" && node.matches(COMMENT_AUTHOR_SELECTOR)) {
          anonymizeCommentAuthor(node)
          return
        }

        anonymizeChatbotCommentAuthors(node)
      })
    })
  })

  observer.observe(document.body, { childList: true, subtree: true })
}

document.addEventListener("DOMContentLoaded", setupChatbotAuthorsAnonymizer)
document.addEventListener("turbo:load", setupChatbotAuthorsAnonymizer)
