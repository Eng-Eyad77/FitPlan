using System.Text;

namespace FitPlan.Api.Services.Exercises;

// Makes Arabic text comparable the way people type it: أ إ آ ٱ → ا, ة → ه, ى → ي, ؤ → و, ئ → ي,
// and no diacritics or tatweel. Latin letters are lower-cased, so mixed names like "بار زد EZ" match too.
public static class ArabicText
{
    public static string Normalize(string text)
    {
        var result = new StringBuilder(text.Length);
        foreach (var c in text)
        {
            switch (c)
            {
                case 'أ' or 'إ' or 'آ' or 'ٱ':
                    result.Append('ا');
                    break;
                case 'ة':
                    result.Append('ه');
                    break;
                case 'ى' or 'ئ':
                    result.Append('ي');
                    break;
                case 'ؤ':
                    result.Append('و');
                    break;
                // tatweel and the harakat (fathatan to sukun, and the dagger alif)
                case 'ـ' or (>= 'ً' and <= 'ْ') or 'ٰ':
                    break;
                default:
                    result.Append(char.ToLowerInvariant(c));
                    break;
            }
        }

        return result.ToString();
    }
}
