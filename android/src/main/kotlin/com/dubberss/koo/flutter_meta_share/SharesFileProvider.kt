// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.share

import androidx.core.content.FileProvider

/**
 * Providing a custom `FileProvider` prevents manifest `<provider>` name collisions.
 *
 *
 * See https://developer.android.com/guide/topics/manifest/provider-element.html for details.
 */
class SharesFileProvider : FileProvider()