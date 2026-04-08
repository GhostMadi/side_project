import 'package:side_project/core/shared/ig_edit/ig_edit_models.dart';

/// Пост-матрица после основного пайплайна (тинт, teal/orange, виньетка, fade).
/// Остальное — в [mergeStylePresetIntoUser].
List<double> postStylePostProcessMatrix4x5(PostStyleFilter f) {
  return switch (f) {
    PostStyleFilter.none ||
    PostStyleFilter.moodyDark ||
    PostStyleFilter.brightAiry ||
    PostStyleFilter.softPortrait ||
    PostStyleFilter.travelBoost ||
    PostStyleFilter.urbanStreet ||
    PostStyleFilter.cleanPro =>
      _identity4x5(),
    PostStyleFilter.goldenInstagram => _tintPlus54x5(),
    PostStyleFilter.vintageFilm => _vintageTintFade4x5(),
    PostStyleFilter.tealOrange => _tealOrange4x5(),
    PostStyleFilter.cinematicDark => _vignetteCinematic4x5(),
  };
}

List<double> _identity4x5() => <double>[
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];

/// Tint +5 (лёгкий розовый).
List<double> _tintPlus54x5() => <double>[
      1.03, 0, 0, 0, 0,
      0, 0.97, 0, 0, 0,
      0, 0, 1.01, 0, 0,
      0, 0, 0, 1, 0,
    ];

/// Tint +6 + fade (поднятие теней / молочность).
List<double> _vintageTintFade4x5() => <double>[
      0.96, 0, 0, 0, 0.045,
      0, 0.94, 0, 0, 0.042,
      0, 0, 0.93, 0, 0.038,
      0, 0, 0, 1, 0,
    ];

/// Упрощённый teal & orange: тёплые красные/оранжевые, холоднее сине-зелёный канал.
List<double> _tealOrange4x5() => <double>[
      1.08, -0.02, 0, 0, 0,
      0.02, 1.05, 0, 0, 0,
      0, 0.03, 1.12, 0, 0,
      0, 0, 0, 1, 0,
    ];

/// Vignette ~−20 (затемнение + лёгкий подъём мидов).
List<double> _vignetteCinematic4x5() => <double>[
      0.88, 0, 0, 0, 0.024,
      0, 0.87, 0, 0, 0.022,
      0, 0, 0.90, 0, 0.020,
      0, 0, 0, 1, 0,
    ];

