use std::ffi::{CStr, CString};
use std::os::raw::c_char;

/// Converts hex string to RGB (0-255). Returns 0 on success, -1 on failure.
#[no_mangle]
pub extern "C" fn rust_hex_to_rgb(
    hex_ptr: *const c_char,
    r: *mut u8,
    g: *mut u8,
    b: *mut u8,
) -> i32 {
    if hex_ptr.is_null() || r.is_null() || g.is_null() || b.is_null() {
        return -1;
    }
    unsafe {
        let c_str = match CStr::from_ptr(hex_ptr).to_str() {
            Ok(s) => s,
            Err(_) => return -1,
        };
        let clean_hex = c_str.trim().trim_start_matches('#');
        if clean_hex.len() != 6 && clean_hex.len() != 8 {
            return -1;
        }
        let hex_val = if clean_hex.len() == 8 {
            &clean_hex[2..]
        } else {
            clean_hex
        };

        if let Ok(val) = u32::from_str_radix(hex_val, 16) {
            *r = ((val >> 16) & 0xFF) as u8;
            *g = ((val >> 8) & 0xFF) as u8;
            *b = (val & 0xFF) as u8;
            0
        } else {
            -1
        }
    }
}

/// Converts RGB to Hex string (#RRGGBB). Out buffer must be at least 8 bytes.
#[no_mangle]
pub extern "C" fn rust_rgb_to_hex(r: u8, g: u8, b: u8, out_buf: *mut c_char) {
    if out_buf.is_null() {
        return;
    }
    let hex_str = format!("#{:02X}{:02X}{:02X}", r, g, b);
    if let Ok(c_string) = CString::new(hex_str) {
        let bytes = c_string.as_bytes_with_nul();
        unsafe {
            std::ptr::copy_nonoverlapping(bytes.as_ptr() as *const c_char, out_buf, bytes.len());
        }
    }
}

/// Converts RGB (0-255) to HSL (H: 0-360, S: 0-1, L: 0-1)
#[no_mangle]
pub extern "C" fn rust_rgb_to_hsl(
    r: u8,
    g: u8,
    b: u8,
    out_h: *mut f32,
    out_s: *mut f32,
    out_l: *mut f32,
) {
    let rf = r as f32 / 255.0;
    let gf = g as f32 / 255.0;
    let bf = b as f32 / 255.0;

    let max = rf.max(gf).max(bf);
    let min = rf.min(gf).min(bf);
    let delta = max - min;

    let l = (max + min) / 2.0;

    let (mut h, mut s) = (0.0f32, 0.0f32);

    if delta.abs() > 1e-5 {
        s = if l > 0.5 {
            delta / (2.0 - max - min)
        } else {
            delta / (max + min)
        };

        if (max - rf).abs() < 1e-5 {
            h = (gf - bf) / delta + (if gf < bf { 6.0 } else { 0.0 });
        } else if (max - gf).abs() < 1e-5 {
            h = (bf - rf) / delta + 2.0;
        } else {
            h = (rf - gf) / delta + 4.0;
        }
        h *= 60.0;
    }

    unsafe {
        if !out_h.is_null() {
            *out_h = h;
        }
        if !out_s.is_null() {
            *out_s = s;
        }
        if !out_l.is_null() {
            *out_l = l;
        }
    }
}

/// Converts HSL (H: 0-360, S: 0-1, L: 0-1) to RGB (0-255)
#[no_mangle]
pub extern "C" fn rust_hsl_to_rgb(
    h: f32,
    s: f32,
    l: f32,
    out_r: *mut u8,
    out_g: *mut u8,
    out_b: *mut u8,
) {
    let h = (h % 360.0 + 360.0) % 360.0;
    let s = s.clamp(0.0, 1.0);
    let l = l.clamp(0.0, 1.0);

    let c = (1.0 - (2.0 * l - 1.0).abs()) * s;
    let x = c * (1.0 - ((h / 60.0) % 2.0 - 1.0).abs());
    let m = l - c / 2.0;

    let (rf, gf, bf) = match (h / 60.0) as i32 {
        0 => (c, x, 0.0),
        1 => (x, c, 0.0),
        2 => (0.0, c, x),
        3 => (0.0, x, c),
        4 => (x, 0.0, c),
        _ => (c, 0.0, x),
    };

    unsafe {
        if !out_r.is_null() {
            *out_r = ((rf + m) * 255.0).round().clamp(0.0, 255.0) as u8;
        }
        if !out_g.is_null() {
            *out_g = ((gf + m) * 255.0).round().clamp(0.0, 255.0) as u8;
        }
        if !out_b.is_null() {
            *out_b = ((bf + m) * 255.0).round().clamp(0.0, 255.0) as u8;
        }
    }
}

/// Converts RGB (0-255) to CMYK (C, M, Y, K: 0-100%)
#[no_mangle]
pub extern "C" fn rust_rgb_to_cmyk(
    r: u8,
    g: u8,
    b: u8,
    out_c: *mut f32,
    out_m: *mut f32,
    out_y: *mut f32,
    out_k: *mut f32,
) {
    let rf = r as f32 / 255.0;
    let gf = g as f32 / 255.0;
    let bf = b as f32 / 255.0;

    let k = 1.0 - rf.max(gf).max(bf);

    let (c, m, y) = if (1.0 - k).abs() < 1e-5 {
        (0.0, 0.0, 0.0)
    } else {
        (
            (1.0 - rf - k) / (1.0 - k),
            (1.0 - gf - k) / (1.0 - k),
            (1.0 - bf - k) / (1.0 - k),
        )
    };

    unsafe {
        if !out_c.is_null() {
            *out_c = c * 100.0;
        }
        if !out_m.is_null() {
            *out_m = m * 100.0;
        }
        if !out_y.is_null() {
            *out_y = y * 100.0;
        }
        if !out_k.is_null() {
            *out_k = k * 100.0;
        }
    }
}

/// Calculates Complementary Color
#[no_mangle]
pub extern "C" fn rust_get_complementary(
    r: u8,
    g: u8,
    b: u8,
    out_r: *mut u8,
    out_g: *mut u8,
    out_b: *mut u8,
) {
    let mut h = 0.0f32;
    let mut s = 0.0f32;
    let mut l = 0.0f32;
    rust_rgb_to_hsl(r, g, b, &mut h, &mut s, &mut l);

    let comp_h = (h + 180.0) % 360.0;
    rust_hsl_to_rgb(comp_h, s, l, out_r, out_g, out_b);
}

/// Calculates Contrast Ratio according to WCAG 2.1 specifications
#[no_mangle]
pub extern "C" fn rust_get_contrast_ratio(
    r1: u8,
    g1: u8,
    b1: u8,
    r2: u8,
    g2: u8,
    b2: u8,
) -> f32 {
    fn luminance(r: u8, g: u8, b: u8) -> f32 {
        fn calc(c: u8) -> f32 {
            let v = c as f32 / 255.0;
            if v <= 0.03928 {
                v / 12.92
            } else {
                ((v + 0.055) / 1.055).powf(2.4)
            }
        }
        0.2126 * calc(r) + 0.7152 * calc(g) + 0.0722 * calc(b)
    }

    let l1 = luminance(r1, g1, b1);
    let l2 = luminance(r2, g2, b2);

    let (max_l, min_l) = if l1 > l2 { (l1, l2) } else { (l2, l1) };
    (max_l + 0.05) / (min_l + 0.05)
}

/// Simulates Colorblindness (mode: 1=Protanopia, 2=Deuteranopia, 3=Tritanopia)
#[no_mangle]
pub extern "C" fn rust_simulate_colorblindness(
    r: u8,
    g: u8,
    b: u8,
    mode: i32,
    out_r: *mut u8,
    out_g: *mut u8,
    out_b: *mut u8,
) {
    fn to_linear(c: u8) -> f32 {
        let v = c as f32 / 255.0;
        if v <= 0.04045 {
            v / 12.92
        } else {
            ((v + 0.055) / 1.055).powf(2.4)
        }
    }

    fn from_linear(v: f32) -> u8 {
        let c = if v <= 0.0031308 {
            v * 12.92
        } else {
            1.055 * v.powf(1.0 / 2.4) - 0.055
        };
        (c * 255.0).round().clamp(0.0, 255.0) as u8
    }

    let rl = to_linear(r);
    let gl = to_linear(g);
    let bl = to_linear(b);

    let (nrl, ngl, nbl) = match mode {
        1 => (
            0.56667 * rl + 0.43333 * gl,
            0.55833 * rl + 0.44167 * gl,
            0.24167 * gl + 0.75833 * bl,
        ),
        2 => (
            0.625 * rl + 0.375 * gl,
            0.7 * rl + 0.3 * gl,
            0.3 * gl + 0.7 * bl,
        ),
        3 => (
            1.01 * rl + 0.02 * gl - 0.03 * bl,
            0.10 * rl + 0.73 * gl + 0.17 * bl,
            0.85 * gl + 0.15 * bl,
        ),
        _ => (rl, gl, bl),
    };

    unsafe {
        if !out_r.is_null() {
            *out_r = from_linear(nrl);
        }
        if !out_g.is_null() {
            *out_g = from_linear(ngl);
        }
        if !out_b.is_null() {
            *out_b = from_linear(nbl);
        }
    }
}

/// Converts wavelength (380 to 780 nm) to RGB
#[no_mangle]
pub extern "C" fn rust_wavelength_to_rgb(
    wavelength: f32,
    out_r: *mut u8,
    out_g: *mut u8,
    out_b: *mut u8,
) {
    let gamma = 0.80f32;
    let (mut r_raw, mut g_raw, mut b_raw) = (0.0f32, 0.0f32, 0.0f32);

    if (380.0..440.0).contains(&wavelength) {
        let attenuation = 0.3 + 0.7 * (wavelength - 380.0) / (440.0 - 380.0);
        r_raw = ((-(wavelength - 440.0) / (440.0 - 380.0)) * attenuation).powf(gamma);
        b_raw = (1.0 * attenuation).powf(gamma);
    } else if (440.0..490.0).contains(&wavelength) {
        g_raw = ((wavelength - 440.0) / (490.0 - 440.0)).powf(gamma);
        b_raw = 1.0;
    } else if (490.0..510.0).contains(&wavelength) {
        g_raw = 1.0;
        b_raw = (-(wavelength - 510.0) / (510.0 - 490.0)).powf(gamma);
    } else if (510.0..580.0).contains(&wavelength) {
        r_raw = ((wavelength - 510.0) / (580.0 - 510.0)).powf(gamma);
        g_raw = 1.0;
    } else if (580.0..645.0).contains(&wavelength) {
        r_raw = 1.0;
        g_raw = (-(wavelength - 645.0) / (645.0 - 580.0)).powf(gamma);
    } else if (645.0..=780.0).contains(&wavelength) {
        let attenuation = 0.3 + 0.7 * (780.0 - wavelength) / (780.0 - 645.0);
        r_raw = (1.0 * attenuation).powf(gamma);
    }

    unsafe {
        if !out_r.is_null() {
            *out_r = (r_raw * 255.0).round().clamp(0.0, 255.0) as u8;
        }
        if !out_g.is_null() {
            *out_g = (g_raw * 255.0).round().clamp(0.0, 255.0) as u8;
        }
        if !out_b.is_null() {
            *out_b = (b_raw * 255.0).round().clamp(0.0, 255.0) as u8;
        }
    }
}
