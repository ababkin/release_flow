module Tags (
    releaseCandidateTagFilter
  , getNextReleaseCandidateTag
  , releaseTagFilter
  , ciTagFilter
  , latestFilteredTag
  , defaultReleaseCandidateTag
  , defaultReleaseTag
  , getReleaseTagFromCandidate
  )
  where

import           Data.List  (sortBy)
import           Data.Maybe (listToMaybe)

import           Types


defaultReleaseCandidateTag = ReleaseCandidateTag (SemVer 0 0 0) 0
defaultReleaseTag = ReleaseTag $ SemVer 0 0 0


getNextReleaseCandidateTag :: Tag -> Tag
getNextReleaseCandidateTag tag =
  ReleaseCandidateTag nextRelease 1
  where
    nextRelease = nextMinorVersion $ version tag

    nextMinorVersion :: Version -> Version
    nextMinorVersion (SemVer major minor patch) = SemVer major (minor + 1) 0


latestFilteredTag :: (Tag -> Bool) -> [Tag] -> Maybe Tag
latestFilteredTag tagsFilter = listToMaybe . reverseSort . filter tagsFilter
  where
    reverseSort :: Ord a => [a] -> [a]
    reverseSort = sortBy $ flip compare

releaseCandidateTagFilter :: Tag -> Bool
releaseCandidateTagFilter (ReleaseCandidateTag _ _) = True
releaseCandidateTagFilter _ = False

releaseTagFilter :: Tag -> Bool
releaseTagFilter (ReleaseTag _) = True
releaseTagFilter _ = False

ciTagFilter :: Tag -> Bool
ciTagFilter (CiTag _) = True
ciTagFilter _ = False

getReleaseTagFromCandidate (ReleaseCandidateTag v _) = ReleaseTag v



