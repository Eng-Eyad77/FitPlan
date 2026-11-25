using FitPlan.Api.Models;
using FitPlan.Api.Services.Exercises;

namespace FitPlan.Api.Services.Email;

// Plain-text emails in the language the app asked for (Accept-Language): Arabic or English.
public static class EmailTexts
{
    public static EmailText Code(EmailCodePurpose purpose, string code, string language)
    {
        var arabic = language == ContentLanguage.Arabic;
        var what = (purpose, arabic) switch
        {
            (EmailCodePurpose.SignUp, true) => "رمز إنشاء حسابك في FitPlan هو",
            (EmailCodePurpose.ResetPassword, true) => "رمز إعادة تعيين كلمة المرور في FitPlan هو",
            (EmailCodePurpose.ChangeEmail, true) => "رمز تأكيد بريدك الإلكتروني الجديد في FitPlan هو",
            (EmailCodePurpose.SignUp, false) => "Your code to create your FitPlan account is",
            (EmailCodePurpose.ResetPassword, false) => "Your code to reset your FitPlan password is",
            _ => "Your code to confirm your new FitPlan email is"
        };

        return arabic
            ? new($"رمز FitPlan: {code}",
                $"{what} {code}\n\nالرمز صالح لمدة 10 دقائق ويُستخدم مرة واحدة. إذا لم تطلب هذا الرمز فتجاهل هذه الرسالة.")
            : new($"Your FitPlan code: {code}",
                $"{what} {code}\n\nIt works once, for 10 minutes. If you didn't ask for it, ignore this email.");
    }

    // To the old address after a change, so the owner notices a change they didn't make.
    public static EmailText EmailChanged(string newEmail, string language) => language == ContentLanguage.Arabic
        ? new("تغيّر بريدك في FitPlan",
            $"تغيّر البريد الإلكتروني لحسابك في FitPlan إلى {newEmail}.\n\nإذا لم تقم بهذا التغيير فردّ على هذه الرسالة وسنساعدك.")
        : new("Your FitPlan email was changed",
            $"The email on your FitPlan account was changed to {newEmail}.\n\nIf you didn't make this change, reply to this email and we'll help you.");
}
